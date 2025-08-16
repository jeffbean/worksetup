#!/bin/bash
set -euo pipefail

copy_base_configs() {
    local base_dir="/home/user/bean-worksetup/devpod/home"

    cp "$base_dir/zshrc" /home/user/.zshrc
    cp "$base_dir/devpod.zsh-theme" /home/user/.oh-my-zsh/themes/
    cp "$base_dir/dot.gitconfig" /home/user/.gitconfig
    cp "$base_dir/dot.gitignore" /home/user/.gitignore

    # Install custom MOTD script
    sudo cp "/home/user/bean-worksetup/devpod/flavors/base/motd-devpod" /etc/update-motd.d/50-bean-devpod
    sudo chmod +x /etc/update-motd.d/50-bean-devpod

    # Set flavor environment variable
    echo 'export BEAN_DEVPOD_FLAVOR="base"' | sudo tee /etc/profile.d/50-bean.sh
    sudo chmod +x /etc/profile.d/50-bean.sh
}

echo "📦 DevPod: Starting base setup..."

echo "🌿 Installing git-spice..."
/usr/local/bin/go install go.abhg.dev/gs@latest

echo "🔧 Setting up configurations..."
copy_base_configs

echo "✅ Base setup complete!"
