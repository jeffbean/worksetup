#!/bin/bash
set -euo pipefail

echo "📦 DevPod: Starting base setup..."

# Install git-spice
echo "🌿 Installing git-spice..."
/usr/local/bin/go install go.abhg.dev/gs@latest

# Copy base configurations
echo "🔧 Setting up base configurations..."
cp /home/user/bean-worksetup/devpod/home/zshrc /home/user/.zshrc
cp /home/user/bean-worksetup/devpod/home/devpod.zsh-theme /home/user/.oh-my-zsh/themes/
cp /home/user/bean-worksetup/devpod/home/dot.gitconfig /home/user/.gitconfig
cp /home/user/bean-worksetup/devpod/home/dot.gitignore /home/user/.gitignore

echo "✅ DevPod: Base setup complete!"