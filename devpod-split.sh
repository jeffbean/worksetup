#!/bin/bash
set -euo pipefail

# Script to create two tmux panes SSH'd to a devpod and jump to project directory
# Usage: devpod-split.sh <devpod-name> <project-name>

display_error() {
    echo "❌ \033[31mERROR:\033[0m $1" >&2
    return 1
}

display_info() {
    echo "ℹ️ \033[34mINFO:\033[0m $1"
}

if [ $# -ne 2 ]; then
    display_error "Usage: $0 <devpod-name> <project-name>"
    echo "Example: $0 bean my-project"
    exit 1
fi

DEVPOD_NAME="$1"
PROJECT_NAME="$2"

# Check if we're in a tmux session
if [ -z "${TMUX:-}" ]; then
    display_error "This script must be run from within a tmux session"
    exit 1
fi

display_info "Finding devpod DNS name for '$DEVPOD_NAME'..."

# Get the devpod list using devpod ps
DEVPOD_OUTPUT=$(devpod ps 2>/dev/null)

if [ -z "$DEVPOD_OUTPUT" ]; then
    display_error "Could not list devpods"
    exit 1
fi

# Find devpod that contains our name (skip header line)
FULL_DEVPOD_NAME=$(echo "$DEVPOD_OUTPUT" | tail -n +3 | awk -v name="$DEVPOD_NAME" '
    $1 ~ name { print $1; exit }
')

if [ -z "$FULL_DEVPOD_NAME" ]; then
    display_error "Could not find devpod matching '$DEVPOD_NAME'"
    echo "Available devpods:"
    echo "$DEVPOD_OUTPUT" | tail -n +3 | awk '{print "  " $1}'
    exit 1
fi

# Check if devpod is running
DEVPOD_STATUS=$(echo "$DEVPOD_OUTPUT" | tail -n +3 | awk -v name="$FULL_DEVPOD_NAME" '
    $1 == name { print $2; exit }
')

if [ "$DEVPOD_STATUS" != "running" ]; then
    display_error "DevPod '$FULL_DEVPOD_NAME' is not running (status: $DEVPOD_STATUS)"
    echo "Start it with: devpod start $FULL_DEVPOD_NAME"
    exit 1
fi

display_info "Found devpod: $FULL_DEVPOD_NAME"

# Use ussh for simplified SSH connections
display_info "Setting up tmux panes for project '$PROJECT_NAME'..."

# Split the current pane horizontally (top and bottom)
tmux split-window -v

# Send ussh command to both panes
tmux send-keys -t 0 "ussh $FULL_DEVPOD_NAME" Enter
tmux send-keys -t 1 "ussh $FULL_DEVPOD_NAME" Enter

# Wait for SSH to connect, then use simple autojump (pre-populated during devpod creation)
(sleep 2 && tmux send-keys -t 0 "j $PROJECT_NAME" Enter) &
(sleep 2 && tmux send-keys -t 1 "j $PROJECT_NAME" Enter) &

# Select the top pane to start
tmux select-pane -t 0

display_info "✅ Setup complete! Both panes are connecting to $FULL_DEVPOD_NAME and jumping to $PROJECT_NAME"
