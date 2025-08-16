#!/bin/bash
set -euo pipefail

echo "📦 DevPod Manual Setup: Installing base devpod configuration manually..."

# Check if we're in the right directory
if [ ! -f "/home/user/bean-worksetup/devpod/flavors/base/on-create.sh" ]; then
    echo "❌ Error: This script must be run with bean-worksetup available"
    echo "📍 Expected: /home/user/bean-worksetup/devpod/flavors/base/on-create.sh"
    exit 1
fi

# Run the initial setup
echo "🚀 Running DevPod initial setup..."
/home/user/bean-worksetup/devpod/flavors/base/on-create.sh

echo ""
echo "✅ DevPod Manual Setup Complete!"
echo ""
echo "🔧 Next steps:"
echo "   1. Restart your shell or run: source ~/.zshrc"
echo "   2. Test git-spice: gs --version"  
echo ""
echo "📖 Your devpod theme should now be active with proper git-spice integration"