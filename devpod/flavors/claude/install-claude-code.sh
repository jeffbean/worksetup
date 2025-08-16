#!/bin/bash
set -euo pipefail

echo "🤖 Installing Claude Code and MCP agents..."

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists claude; then
    echo "📦 Installing Claude Code CLI via aifx..."
    aifx agent install claude
    echo "✅ Claude Code installed successfully"
else
    echo "✅ Claude Code already installed"
fi

echo "📦 Installing MCP agents..."
mkdir -p ~/.claude
aifx mcp install --all

echo "✅ Setup complete!"
