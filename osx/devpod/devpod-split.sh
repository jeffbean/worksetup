#!/bin/bash
set -euo pipefail

# Script to create two tmux panes SSH'd to a devpod and jump to project directory
# Usage: devpod-split.sh <devpod-name> <project-name>

# Debug logging - consolidated log file
DEBUG_LOG="/tmp/devpod-debug.log"
exec 2>> "$DEBUG_LOG"
echo "$(date): [SPLIT] devpod-split.sh started with args: $*" >> "$DEBUG_LOG"

# ============================================================================
# Utility Functions
# ============================================================================

display_error() {
    # Log debug info and show tmux status message
    echo "$(date): [SPLIT] ERROR: $1" >> "$DEBUG_LOG"
    tmux display-message "❌ ERROR: $1" 2>/dev/null || echo -e "❌ \033[31mERROR:\033[0m $1" >&2
    return 1
}

display_info() {
    # Log debug info and show tmux status message
    echo "$(date): [SPLIT] INFO: $1" >> "$DEBUG_LOG"
    tmux display-message "ℹ️ $1" 2>/dev/null || true
}

# ============================================================================
# Core Functions
# ============================================================================

parse_arguments() {
    if [ $# -eq 1 ]; then
        # Handle single argument with space-separated values (from tmux prompt)
        read -r DEVPOD_NAME PROJECT_NAME <<< "$1"
    elif [ $# -eq 2 ]; then
        # Handle traditional two arguments
        DEVPOD_NAME="$1"
        PROJECT_NAME="$2"
    else
        display_error "Usage: $0 <devpod-name> <project-name>"
        display_info "Example: $0 bean my-project"
        display_info "   Or: $0 'bean my-project'"
        exit 1
    fi

    if [ -z "$DEVPOD_NAME" ] || [ -z "$PROJECT_NAME" ]; then
        display_error "Both devpod name and project name are required"
        display_info "Example: $0 bean my-project"
        exit 1
    fi
}

validate_environment() {
    # Check if we're in a tmux session
    if [ -z "${TMUX:-}" ]; then
        display_error "This script must be run from within a tmux session"
        exit 1
    fi
}

find_and_validate_devpod() {
    display_info "Finding devpod '$DEVPOD_NAME'..."

    # Get the devpod list using devpod ps
    local devpod_output=$(devpod ps 2>/dev/null)

    if [ -z "$devpod_output" ]; then
        display_error "Could not list devpods"
        exit 1
    fi

    # Find devpod that contains our name (skip header line)
    FULL_DEVPOD_NAME=$(echo "$devpod_output" | tail -n +3 | awk -v name="$DEVPOD_NAME" '
        $1 ~ name { print $1; exit }
    ')

    if [ -z "$FULL_DEVPOD_NAME" ]; then
        local available=$(echo "$devpod_output" | tail -n +3 | awk '{print $1}' | tr '\n' ' ')
        display_error "Devpod '$DEVPOD_NAME' not found. Available: $available"
        exit 1
    fi

    # Check if devpod is running
    local devpod_status=$(echo "$devpod_output" | tail -n +3 | awk -v name="$FULL_DEVPOD_NAME" '
        $1 == name { print $2; exit }
    ')

    if [ "$devpod_status" != "running" ]; then
        display_error "DevPod '$FULL_DEVPOD_NAME' not running ($devpod_status). Start with: devpod start $FULL_DEVPOD_NAME"
        exit 1
    fi

    display_info "Found devpod: $FULL_DEVPOD_NAME"
}

generate_names() {
    WINDOW_NAME="dp-$(echo $DEVPOD_NAME | cut -d'-' -f1)-$PROJECT_NAME"
    PANE_AI_NAME="🤖 AI-$PROJECT_NAME"
    PANE_TERM_NAME="💻 Term-$PROJECT_NAME"
}

check_existing_session() {
    local existing_window=$(tmux list-windows -F "#{window_name}" 2>/dev/null | grep "^$WINDOW_NAME$" || true)
    
    if [ -n "$existing_window" ]; then
        display_info "Found window '$WINDOW_NAME', checking panes..."
        tmux select-window -t "$WINDOW_NAME"
        
        # Check if our specific panes exist in this window
        local ai_pane=$(tmux list-panes -t "$WINDOW_NAME" -F "#{pane_id} #{pane_title}" 2>/dev/null | grep "$PANE_AI_NAME" | cut -d' ' -f1 || true)
        local term_pane=$(tmux list-panes -t "$WINDOW_NAME" -F "#{pane_id} #{pane_title}" 2>/dev/null | grep "$PANE_TERM_NAME" | cut -d' ' -f1 || true)
        
        if [ -n "$ai_pane" ] && [ -n "$term_pane" ]; then
            display_info "✅ Found existing panes, switching to AI pane"
            tmux select-window -t "$WINDOW_NAME"
            tmux select-pane -t "$ai_pane"
            return 0  # Perfect session found
        else
            display_info "Reconstructing panes for '$PROJECT_NAME'..."
            reconstruct_window_layout
            return 0  # Window reconstructed
        fi
    fi
    
    return 1  # No existing session found
}

reconstruct_window_layout() {
    # Simpler approach: just break all panes and restart
    local current_window=$(tmux display-message -p "#{window_index}")
    
    # Kill all panes except the first one (safer approach)
    while [ "$(tmux list-panes -t "$current_window" | wc -l)" -gt 1 ]; do
        tmux kill-pane -t "$current_window.1" 2>/dev/null || break
    done
    
    # Clear any scroll mode and reset the remaining pane
    tmux send-keys -t "$current_window.0" -X cancel 2>/dev/null || true
    tmux send-keys -t "$current_window.0" C-c 2>/dev/null || true
    tmux send-keys -t "$current_window.0" "clear" Enter 2>/dev/null || true
    
    # Now we have a single clean pane, reconstruct the layout
    split_and_name_panes
    setup_devpod_session
}

split_and_name_panes() {
    # Get the current pane ID before splitting
    CURRENT_PANE=$(tmux display-message -p "#{pane_id}")
    
    # Split the current pane horizontally (top and bottom)
    tmux split-window -v
    
    # Get the new pane ID (the one we just created)
    NEW_PANE=$(tmux list-panes -F "#{pane_id}" | grep -v "$CURRENT_PANE" | head -n 1)
    
    # Name the panes for better identification
    tmux select-pane -t "$CURRENT_PANE" -T "$PANE_AI_NAME"
    tmux select-pane -t "$NEW_PANE" -T "$PANE_TERM_NAME"
}

create_pane_layout() {
    local pane_count=$(tmux list-panes | wc -l)
    
    if [ "$pane_count" -gt 1 ]; then
        display_info "Creating new window '$WINDOW_NAME'..."
        
        # Create a new window for this project
        tmux new-window -n "$WINDOW_NAME"
        split_and_name_panes
    else
        display_info "Splitting current window for '$PROJECT_NAME'..."
        
        # Rename current window to our project window
        tmux rename-window "$WINDOW_NAME"
        split_and_name_panes
    fi
}

setup_devpod_session() {
    # Send ussh command to both specific panes
    tmux send-keys -t "$CURRENT_PANE" "ussh $FULL_DEVPOD_NAME" Enter
    tmux send-keys -t "$NEW_PANE" "ussh $FULL_DEVPOD_NAME" Enter
    
    # Wait for SSH to connect, then jump to project
    # Top pane (current): jump to project  
    (sleep 2 && tmux send-keys -t "$CURRENT_PANE" "j $PROJECT_NAME" Enter) &
    # Bottom pane (new): just jump to project directory
    (sleep 2 && tmux send-keys -t "$NEW_PANE" "j $PROJECT_NAME" Enter) &
    
    # TODO: Temporarily disabled crun and clear to test scroll mode issue
    # (sleep 4 && tmux send-keys -t "$CURRENT_PANE" "clear" Enter) &
    # (sleep 5 && tmux send-keys -t "$CURRENT_PANE" "crun" Enter) &
    
    # Select the top pane to start
    tmux select-pane -t "$CURRENT_PANE"
    
    # Always switch to the target window (in case user was in different window)
    tmux select-window -t "$WINDOW_NAME"
    
    display_info "✅ Ready! Window: $WINDOW_NAME (run 'crun' in top pane)"
}

# ============================================================================
# Main Script
# ============================================================================

parse_arguments "$@"
validate_environment
find_and_validate_devpod
generate_names

# Try to find existing session first
if check_existing_session; then
    exit 0
fi

# Create new session
create_pane_layout
setup_devpod_session

# Final window switch to ensure user lands in the right place
tmux select-window -t "$WINDOW_NAME" 2>/dev/null || true
