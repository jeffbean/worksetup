#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')

# Apply your preferred path trimming logic
trimmed=$(echo "$cwd" | sed -E 's|.*/src/code\.uber\.internal/||; s|.*/idl/code\.uber\.internal/||')

# Get git branch info without changing directories
branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# Get hostname for the prompt
hostname_short=$(hostname -s)

# Build the prompt based on your devpod theme
# Using the "c:" style (code/agent environment) since this is Claude Code
if [ -n "$branch" ]; then
    # [c: hostname(git_branch)] [model]: path
    printf '\033[2m[c: \033[36m%s\033[0m\033[2m\033[33m(g:%s)\033[0m\033[2m] [\033[32m%s\033[0m\033[2m]: \033[34m%s\033[0m\033[2m\033[0m' "$hostname_short" "$branch" "$model_name" "$trimmed"
else
    # [c: hostname] [model]: path  
    printf '\033[2m[c: \033[36m%s\033[0m\033[2m] [\033[32m%s\033[0m\033[2m]: \033[34m%s\033[0m\033[2m\033[0m' "$hostname_short" "$model_name" "$trimmed"
fi