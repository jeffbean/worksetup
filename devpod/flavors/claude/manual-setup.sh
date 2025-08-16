#!/bin/bash
set -euo pipefail

echo "🤖 Claude Manual Setup: Installing Claude configuration manually..."

# Check if we're in the right directory
if [ ! -f "/home/user/bean-worksetup/devpod/flavors/claude/on-create.sh" ]; then
    echo "❌ Error: This script must be run with bean-worksetup available"
    echo "📍 Expected: /home/user/bean-worksetup/devpod/flavors/claude/on-create.sh"
    exit 1
fi

# Run the initial setup
echo "🚀 Running Claude initial setup..."
/home/user/bean-worksetup/devpod/flavors/claude/on-create.sh

echo ""
echo "✅ Claude Manual Setup Complete!"
echo ""
echo "🔧 Next steps:"
echo "   1. Restart your shell or run: source ~/.zshrc"
echo "   2. Test Claude statusline and environment"
echo ""
echo "📖 For more info, see: /home/user/bean-worksetup/devpod/claude/README.md"