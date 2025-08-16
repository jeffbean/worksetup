#!/bin/bash
set -euo pipefail

echo "🤖 Claude DevPod: Starting initial setup..."

# Run base devpod setup first
echo "📦 Running base devpod setup..."
/home/user/bean-worksetup/devpod/flavors/base/on-create.sh

# Set up Claude-specific directory structure
echo "📁 Creating Claude directories..."
mkdir -p /home/user/.claude

# Copy Claude configurations
echo "⚙️  Setting up Claude configurations..."
cp /home/user/bean-worksetup/devpod/home/dotclaude/settings.json /home/user/.claude/
cp /home/user/bean-worksetup/devpod/home/dotclaude/statusline-devpod.sh /home/user/.claude/
cp /home/user/bean-worksetup/devpod/home/claude.zshrc /home/user/.zshrc.claude
chmod +x /home/user/.claude/statusline-devpod.sh

# Append Claude-specific configurations to zshrc
echo "🤖 Adding Claude integration to zshrc..."
cat >> /home/user/.zshrc << 'EOF'

# Claude AI specific additions
if [ -f ~/.zshrc.claude ]; then
    source ~/.zshrc.claude
fi
EOF

# Add git-spice configuration
echo "🌿 Setting up git-spice..."
cat >> /home/user/.gitconfig << 'EOF'

# Claude AI specific git settings
[spice]
  submit.publish = false
  branchCreate.prefix = "bean/"
EOF

echo "✅ Claude DevPod: Initial setup complete!"
echo "🤖 BEAN_CODE_ENABLED is set for proper prompt formatting"
echo "📊 Claude statusline and settings configured"
echo "🌿 Git-spice configured with bean/ prefix"