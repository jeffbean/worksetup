#!/bin/bash
set -euo pipefail

setup_claude_configs() {
    local claude_dir="/home/user/bean-worksetup/devpod/home/dotclaude"
    
    mkdir -p /home/user/.claude
    cp "$claude_dir/settings.json" /home/user/.claude/
    cp "$claude_dir/statusline-devpod.sh" /home/user/.claude/
    chmod +x /home/user/.claude/statusline-devpod.sh
    
    # Override flavor environment variable to claude
    echo 'export BEAN_DEVPOD_FLAVOR="claude"' | sudo tee /etc/profile.d/50-bean.sh
    sudo chmod 644 /etc/profile.d/50-bean.sh
}

echo "🤖 Claude DevPod: Starting setup..."

echo "📦 Running base devpod setup..."
/home/user/bean-worksetup/devpod/flavors/base/on-create.sh

echo "📁 Setting up Claude configuration..."
setup_claude_configs

echo "✅ Claude DevPod setup complete!"