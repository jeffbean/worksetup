#!/bin/bash
set -euo pipefail

copy_base_configs() {
    local base_dir="/home/user/bean-worksetup/devpod/home"

    [ -f "$base_dir/zshrc" ] && cp "$base_dir/zshrc" /home/user/.zshrc
    [ -f "$base_dir/devpod.zsh-theme" ] && cp "$base_dir/devpod.zsh-theme" /home/user/.oh-my-zsh/themes/
    [ -f "$base_dir/dot.gitconfig" ] && cp "$base_dir/dot.gitconfig" /home/user/.gitconfig
    [ -f "$base_dir/dot.gitignore" ] && cp "$base_dir/dot.gitignore" /home/user/.gitignore
    
    # Update custom MOTD script
    if [ -f "/home/user/bean-worksetup/devpod/flavors/base/motd-devpod" ]; then
        sudo cp "/home/user/bean-worksetup/devpod/flavors/base/motd-devpod" /etc/update-motd.d/50-bean-devpod
        sudo chmod +x /etc/update-motd.d/50-bean-devpod
    fi
    
    # Set flavor environment variable
    echo 'export BEAN_DEVPOD_FLAVOR="base"' | sudo tee /etc/profile.d/50-bean.sh
    sudo chmod +x /etc/profile.d/50-bean.sh
}

echo "🔄 DevPod: Running base update..."

echo "🔧 Refreshing configurations..."
copy_base_configs

echo "📦 Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

echo "🌿 Updating git-spice..."
/usr/local/bin/go install go.abhg.dev/gs@latest


echo "✅ Base update complete!"
