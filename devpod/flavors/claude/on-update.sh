#!/bin/bash
set -euo pipefail

refresh_claude_configs() {
    local claude_dir="/home/user/bean-worksetup/devpod/home/dotclaude"
    
    [ -f "$claude_dir/settings.json" ] && cp "$claude_dir/settings.json" /home/user/.claude/
    [ -f "$claude_dir/statusline-devpod.sh" ] && {
        cp "$claude_dir/statusline-devpod.sh" /home/user/.claude/
        chmod +x /home/user/.claude/statusline-devpod.sh
    }
    
    # Override flavor environment variable to claude
    echo 'export BEAN_DEVPOD_FLAVOR="claude"' | sudo tee /etc/profile.d/50-bean.sh
    sudo chmod 644 /etc/profile.d/50-bean.sh
}

echo "🔄 Claude DevPod: Running update..."

echo "📦 Running base devpod update..."
/home/user/bean-worksetup/devpod/flavors/base/on-update.sh

echo "⚙️ Refreshing Claude configurations..."
refresh_claude_configs

echo "✅ Update complete!"
