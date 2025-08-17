#!/bin/bash
set -euo pipefail

setup_claude_configs() {
    local claude_dir="/home/user/bean-worksetup/devpod/home/dotclaude"
    
    mkdir -p /home/user/.claude
    cp "$claude_dir/settings.json" /home/user/.claude/
    cp "$claude_dir/statusline-devpod.sh" /home/user/.claude/
    chmod +x /home/user/.claude/statusline-devpod.sh
    
    # Write configuration with claude flavor
    write_profile_config "claude"
}

echo "🤖 Claude DevPod: Starting setup..."

echo "📦 Running base devpod setup..."
# Source shared functions and load config
source "/home/user/bean-worksetup/devpod/flavors/base/shared-functions.sh"

load_config

echo "🔧 Setting up base configurations..."
copy_base_configs

setup_autojump_database

echo "📁 Setting up Claude configuration..."
setup_claude_configs

echo "✅ Claude DevPod setup complete!"