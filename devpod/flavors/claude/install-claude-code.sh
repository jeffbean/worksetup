#!/bin/bash
set -uo pipefail

echo "🤖 Setting up Claude Code and MCP agents..."

echo "📦 Updating system packages..."
sudo apt-get update

echo "📦 Updating uber-aifx package..."
sudo apt-get install --only-upgrade uber-aifx -y

echo "📦 Installing Claude Code CLI via aifx..."
if ! aifx agent install claude; then
    echo "⚠️ Claude Code installation requires interactive authentication"
    echo "   Run 'aifx agent install claude' manually after devpod setup"
fi

mkdir -p ~/.claude
echo "📦 Installing MCP agents..."
if ! aifx mcp install phab; then
    echo "⚠️ MCP phab installation may require authentication"
fi

if ! aifx mcp install t3; then
    echo "⚠️ MCP t3 installation may require authentication"
fi

if ! aifx mcp install code-reviewer; then
    echo "⚠️ MCP code-reviewer installation may require authentication"
fi

echo "✅ Setup complete! (Some installations may need manual authentication)"
