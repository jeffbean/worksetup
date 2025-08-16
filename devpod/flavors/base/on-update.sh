#!/bin/bash
set -euo pipefail

echo "🔄 DevPod: Running base update..."

# Update git-spice if needed
echo "🌿 Updating git-spice..."
/usr/local/bin/go install go.abhg.dev/gs@latest

# Refresh base configurations if they exist
echo "🔧 Refreshing base configurations..."
if [ -f /home/user/bean-worksetup/devpod/home/devpod.zsh-theme ]; then
    cp /home/user/bean-worksetup/devpod/home/devpod.zsh-theme /home/user/.oh-my-zsh/themes/
fi

echo "✅ DevPod: Base update complete!"