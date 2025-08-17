#!/bin/bash
set -euo pipefail

# Simple visual devpod selector popup
# Returns just the selected devpod name

# Debug logging - consolidated log file
DEBUG_LOG="/tmp/devpod-debug.log"
exec 2>> "$DEBUG_LOG"
echo "$(date): [SELECTOR] devpod-selector.sh started" >> "$DEBUG_LOG"

# Get devpod list
devpod_output=$(devpod ps 2>/dev/null)
if [ -z "$devpod_output" ]; then
    echo "ERROR: Could not list devpods" >&2
    exit 1
fi

# Create simple menu
temp_menu="/tmp/devpod-selector-$$"
declare -a devpod_names=()

echo "📦 Select DevPod:" > "$temp_menu"
echo "==================" >> "$temp_menu"

counter=1
while IFS= read -r line; do
    if [ -n "$line" ]; then
        name=$(echo "$line" | awk '{print $1}')
        status=$(echo "$line" | awk '{print $2}')
        short_name=$(echo "$name" | sed 's/\.devpod-us-or$//')
        
        status_icon="🔴"
        [ "$status" = "running" ] && status_icon="🟢"
        
        printf "%d) %s %s [%s]\n" "$counter" "$status_icon" "$short_name" "$status" >> "$temp_menu"
        devpod_names[$counter]="$short_name"
        ((counter++))
    fi
done <<< "$(echo "$devpod_output" | tail -n +3)"

echo "" >> "$temp_menu"

echo "$(date): [SELECTOR] Created menu with ${#devpod_names[@]} devpods" >> "$DEBUG_LOG"

# Show popup and get selection
cat "$temp_menu"
echo -n "Enter number: "
read choice

# Clean up
rm -f "$temp_menu"

echo "$(date): [SELECTOR] User selected: '$choice'" >> "$DEBUG_LOG"

# Validate selection and proceed with project prompt
if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#devpod_names[@]}" ]; then
    selected="${devpod_names[$choice]}"
    echo "$(date): Selected devpod: '$selected'" >> "$DEBUG_LOG"
    
    echo ""
    echo "Selected: $selected"
    echo -n "Project name: "
    read project_name
    
    if [ -n "$project_name" ]; then
        echo "$(date): [SELECTOR] Executing devpod-split.sh $selected $project_name" >> "$DEBUG_LOG"
        
        # Quick feedback and close popup fast
        echo "✅ Connecting to $selected/$project_name..."
        
        # Use tmux to run the devpod-split script
        tmux run-shell "~/worksetup/devpod-split.sh '$selected' '$project_name'" &
        
        # Brief pause to show confirmation, then exit to close popup quickly
        sleep 0.2
        exit 0
    else
        echo "❌ Project name required"
        sleep 1
        exit 1
    fi
else
    echo "$(date): [SELECTOR] Invalid selection: '$choice'" >> "$DEBUG_LOG"
    echo "❌ Invalid selection" >&2
    exit 1
fi
