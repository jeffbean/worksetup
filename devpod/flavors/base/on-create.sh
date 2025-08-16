#!/bin/bash
set -euo pipefail

copy_base_configs() {
    local base_dir="/home/user/bean-worksetup/devpod/home"
    
    cp "$base_dir/zshrc" /home/user/.zshrc
    cp "$base_dir/devpod.zsh-theme" /home/user/.oh-my-zsh/themes/
    cp "$base_dir/dot.gitconfig" /home/user/.gitconfig
    cp "$base_dir/dot.gitignore" /home/user/.gitignore
}

echo "📦 DevPod: Starting base setup..."

echo "🌿 Installing git-spice..."
/usr/local/bin/go install go.abhg.dev/gs@latest

echo "🔧 Setting up configurations..."
copy_base_configs

echo "✅ Base setup complete!"