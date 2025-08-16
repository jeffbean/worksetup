#!/bin/bash
set -euo pipefail

echo "🔄 Claude DevPod: Running update..."

# Run base devpod update first
echo "📦 Running base devpod update..."
/home/user/bean-worksetup/devpod/flavors/base/on-update.sh

# Refresh Claude configurations (in case they changed)
echo "⚙️  Refreshing Claude configurations..."
if [ -f /home/user/bean-worksetup/devpod/home/dotclaude/settings.json ]; then
    cp /home/user/bean-worksetup/devpod/home/dotclaude/settings.json /home/user/.claude/
fi

if [ -f /home/user/bean-worksetup/devpod/home/dotclaude/statusline-devpod.sh ]; then
    cp /home/user/bean-worksetup/devpod/home/dotclaude/statusline-devpod.sh /home/user/.claude/
    chmod +x /home/user/.claude/statusline-devpod.sh
fi

if [ -f /home/user/bean-worksetup/devpod/home/claude.zshrc ]; then
    cp /home/user/bean-worksetup/devpod/home/claude.zshrc /home/user/.zshrc.claude
fi

# Check if Claude environment is properly sourced in zshrc
if ! grep -q "source ~/.zshrc.claude" /home/user/.zshrc 2>/dev/null; then
    echo "🤖 Adding Claude integration to zshrc..."
    cat >> /home/user/.zshrc << 'EOF'

# Claude AI specific additions
if [ -f ~/.zshrc.claude ]; then
    source ~/.zshrc.claude
fi
EOF
fi

echo "✅ Claude DevPod: Update complete!"
echo "🔄 All configurations refreshed"
echo "🤖 Claude environment ready"