#!/bin/bash

# Debug log viewer for devpod scripts
# Usage: ./debug-devpod.sh [clear]

if [ "$1" = "clear" ]; then
    echo "🧹 Clearing debug log..."
    rm -f /tmp/devpod-debug.log
    echo "✅ Debug log cleared"
    exit 0
fi

echo "🔍 DevPod Scripts Debug Log:"
echo ""

if [ -f "/tmp/devpod-debug.log" ]; then
    echo "📋 Consolidated debug log (last 30 lines):"
    echo "========================================="
    tail -30 "/tmp/devpod-debug.log"
    echo ""
else
    echo "⚠️ No debug log found."
    echo "Run a devpod command first (Ctrl+a d), then check logs again."
fi

echo "💡 Usage:"
echo "  ./debug-devpod.sh       - View logs"
echo "  ./debug-devpod.sh clear - Clear logs"
