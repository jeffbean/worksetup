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

# install the mcp for claude. 
for agent in t3 phab code-reviewer buildkite engwiki databook-mcp-server; do
    aifx mcp install "$agent"
    aifx agent run claude mcp add -s user "$agent" aifx mcp run "$agent"
done

echo "✅ Setup complete! (Some installations may need manual authentication)"
