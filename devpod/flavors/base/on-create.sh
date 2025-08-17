#!/bin/bash
set -euo pipefail

# Source shared functions
source "/home/user/bean-worksetup/devpod/flavors/base/shared-functions.sh"

# Load configuration
load_config

echo "📦 DevPod: Starting base setup..."

echo "🌿 Installing git-spice..."
/usr/local/bin/go install go.abhg.dev/gs@latest

echo "🔧 Setting up configurations..."
copy_base_configs
 
echo "📁 Pre-populating autojump database with infra projects..."
setup_autojump_database

echo "✅ Base setup complete!"
