#!/bin/bash
set -euo pipefail

# Source shared functions
source "/home/user/bean-worksetup/devpod/flavors/base/shared-functions.sh"

# Load configuration
load_config

echo "🔄 DevPod: Running base update..."

update_base_configs

echo "📦 Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

echo "🌿 Updating git-spice..."
/usr/local/bin/go install go.abhg.dev/gs@latest

echo "✅ Base update complete!"
