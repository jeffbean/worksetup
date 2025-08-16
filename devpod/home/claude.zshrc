# Claude Code Environment Configuration
# This file is sourced by ~/.zshrc when in Claude environments

# Claude-specific environment variables
export BEAN_CODE_ENABLED=1
export CLAUDE_AI_MODE=1

# Uber environment (inherited from main devpod config)
export UBER_OWNER="bean@uber.com"
export UBER_LDAP_UID="bean"  
export KUBECONFIG="$HOME/.kube/uconfig"