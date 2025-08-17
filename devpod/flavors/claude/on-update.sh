#!/bin/bash
set -euo pipefail

refresh_claude_configs() {
    local claude_dir="/home/user/bean-worksetup/devpod/home/dotclaude"
    
    [ -f "$claude_dir/settings.json" ] && cp "$claude_dir/settings.json" /home/user/.claude/
    [ -f "$claude_dir/statusline-devpod.sh" ] && {
        cp "$claude_dir/statusline-devpod.sh" /home/user/.claude/
        chmod +x /home/user/.claude/statusline-devpod.sh
    }
    
    # Write configuration with claude flavor
    write_profile_config "claude"
}

echo "🔄 Claude DevPod: Running update..."

echo "📦 Running base devpod update..."
# Source shared functions and load config
source "/home/user/bean-worksetup/devpod/flavors/base/shared-functions.sh"
load_config

# Run base update components but skip config loading since we already did it
echo "🔧 Refreshing configurations..."
update_base_configs

echo "📦 Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

echo "🌿 Updating git-spice..."
/usr/local/bin/go install go.abhg.dev/gs@latest

echo "⚙️ Refreshing Claude configurations..."
refresh_claude_configs

echo "✅ Update complete!"
