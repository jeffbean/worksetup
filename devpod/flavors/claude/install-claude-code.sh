#!/bin/bash
set -euo pipefail

echo "🤖 Installing Claude Code and MCP agents..."

echo "📦 Installing Claude Code CLI via aifx..."
aifx agent install claude

mkdir -p ~/.claude
echo "📦 Installing MCP agents..."
aifx mcp install phab
aifx mcp install t3
aifx mcp install code-reviewer

echo "✅ Setup complete!"
