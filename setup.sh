#!/bin/bash
set -euo pipefail

# macOS Work Environment Setup Script
# Run from the worksetup git repository directory

# ============================================================================
# Setup Functions
# ============================================================================

display_info() {
    echo "ℹ️ $1"
}

display_success() {
    echo "✅ $1"
}

display_error() {
    echo "❌ $1" >&2
    return 1
}

# Get the directory where this script is located (the repo root)
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
display_info "Using repository at: $REPO_ROOT"

# Validate we're in the right place
if [ ! -f "$REPO_ROOT/osx/Brewfile" ]; then
    display_error "Cannot find osx/Brewfile. Please run this script from the worksetup repository root."
    exit 1
fi

# ============================================================================
# System Prerequisites
# ============================================================================

setup_permissions() {
    display_info "Setting up system permissions..."
    
    # SSH directory
    if [ -d "$HOME/.ssh" ]; then
        if [ ! -w "$HOME/.ssh" ]; then
            display_info "Fixing SSH directory permissions..."
            sudo chown -R $(whoami) "$HOME/.ssh"
        fi
    else
        mkdir -p "$HOME/.ssh"
    fi
    
    # Homebrew directories - only fix if we can't write to them
    for dir in "$HOME/Library/Caches/Homebrew/" "$HOME/.cache" /usr/local/Caskroom /usr/local/sbin /usr/local/lib /usr/local/share; do
        if [ -d "$dir" ] && [ ! -w "$dir" ]; then
            display_info "Fixing permissions for $dir..."
            sudo chown -R $(whoami) "$dir"
        fi
    done
    
    # Special case for dnscrypt-proxy
    if [ -d /usr/local/lib/dnscrypt-proxy ] && [ ! -w /usr/local/lib/dnscrypt-proxy ]; then
        display_info "Setting dnscrypt-proxy permissions..."
        sudo chown -R root:wheel /usr/local/lib/dnscrypt-proxy
    fi
    
    # Clean up old uber tap if it exists
    if [ -d /usr/local/Homebrew/Library/Taps/uber/homebrew-alt ]; then
        display_info "Cleaning up old Uber Homebrew tap..."
        rm -rf /usr/local/Homebrew/Library/Taps/uber/homebrew-alt
    fi
    
    display_success "System permissions configured"
}

setup_xcode() {
    display_info "Setting up Xcode tools..."
    
    if [ -e "/Applications/Xcode.app" ]; then
        xcode-select --install 2>/dev/null || display_info "Xcode command line tools already installed"
        
        # Only try to accept license if we haven't already
        if ! xcodebuild -license check 2>/dev/null; then
            display_info "Accepting Xcode license..."
            sudo xcodebuild -license accept
        else
            display_info "Xcode license already accepted"
        fi
        
        display_success "Xcode tools configured"
    else
        display_info "Xcode not found, skipping Xcode setup"
    fi
}

install_homebrew_packages() {
    display_info "Installing Homebrew packages..."
    
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
    brew analytics off 2>&1 >/dev/null || true
    
    # Run brew bundle and capture output
    if brew bundle --file="$REPO_ROOT/osx/Brewfile" 2>&1 | tee /tmp/brew-bundle.log; then
        display_success "Homebrew packages installed"
    else
        # Check if the error is just the adoptopenjdk8 issue
        if grep -q "adoptopenjdk8" /tmp/brew-bundle.log && grep -q "brew bundle.*complete" /tmp/brew-bundle.log; then
            display_info "Homebrew packages installed (ignoring adoptopenjdk8 error)"
            display_success "Homebrew packages installed"
        else
            display_error "Failed to install Homebrew packages"
            exit 1
        fi
    fi
}

setup_git() {
    display_info "Setting up git..."
    # Backup existing config if it exists
    if [ -f "$HOME/.bean_gitconfig" ]; then
        cp "$HOME/.bean_gitconfig" "$HOME/.bean_gitconfig.backup.$(date +%s)"
    fi
    cp "$REPO_ROOT/osx/home/gitconfig" "$HOME/.bean_gitconfig"

    # Add conditional include to ~/.gitconfig if it doesn't exist
    if [ ! -f "$HOME/.gitconfig" ]; then
        echo "[includeIf \"gitdir:~/\"]\n    path = ~/.bean_gitconfig" > "$HOME/.gitconfig"
    else
        if ! grep -q "path = ~/.bean_gitconfig" "$HOME/.gitconfig"; then
            echo -e "\n[includeIf \"gitdir:~/\"]\n    path = ~/.bean_gitconfig" >> "$HOME/.gitconfig"
        fi
    fi
    
    display_success "Git configuration installed"
}

setup_tmux() {
    display_info "Setting up tmux..."
    
    # Install tmux plugin manager if not present
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        display_success "Installed tmux plugin manager"
    else
        display_info "Tmux plugin manager already installed"
    fi
    
               # Copy tmux configuration
           if [ -f "$HOME/.tmux.conf" ]; then
               cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%s)"
           fi
           cp "$REPO_ROOT/osx/home/dot_tmux.conf" "$HOME/.tmux.conf"
    display_success "Tmux configuration installed"
}

setup_powerline() {
    display_info "Setting up powerline..."
    
    mkdir -p "$HOME/Virtualenvs"
    
    if [ ! -d "$HOME/Virtualenvs/tmux-plugins" ]; then
        python3 -m venv "$HOME/Virtualenvs/tmux-plugins"
        display_success "Created powerline virtual environment"
    fi
    
    source "$HOME/Virtualenvs/tmux-plugins/bin/activate"
    pip install powerline-status
    display_success "Powerline installed"
}

setup_zsh() {
    display_info "Setting up zsh and oh-my-zsh..."
    
    # Install oh-my-zsh if not present
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        display_info "Installing oh-my-zsh (this may prompt for input)..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
        display_success "Oh-my-zsh installed"
    else
        display_info "Oh-my-zsh already installed"
    fi
    
    # Copy configurations
    if [ -f "$HOME/.vimrc" ]; then
        cp "$HOME/.vimrc" "$HOME/.vimrc.backup.$(date +%s)"
    fi
    cp "$REPO_ROOT/osx/home/dot_vimrc" "$HOME/.vimrc"

    # Setup zsh additional configurations
    mkdir -p "$HOME/.zsh/rc.d"
    if [ -d "$REPO_ROOT/osx/home/zsh/rc.d" ]; then
        rsync -a "$REPO_ROOT/osx/home/zsh/rc.d/" "$HOME/.zsh/rc.d/"
        display_success "Zsh additional configurations copied"
    fi
    
    # Copy custom theme
    if [ -f "$REPO_ROOT/common/bean.zsh-theme" ]; then
        cp "$REPO_ROOT/common/bean.zsh-theme" "$HOME/.oh-my-zsh/themes/"
        display_success "Custom zsh theme installed"
    fi
}

setup_devpod_automation() {
    display_info "Setting up DevPod automation tools..."
    
    # Verify devpod scripts exist
    if [ ! -d "$REPO_ROOT/osx/devpod" ]; then
        display_info "No devpod automation found, skipping"
        return
    fi
    
    # Make scripts executable in place
    chmod +x "$REPO_ROOT/osx/devpod"/*.sh 2>/dev/null || true
    display_success "DevPod scripts made executable"
        
    display_info ""
    display_info "📋 DevPod Tmux Key Bindings (after tmux restart):"
    display_info "   Ctrl+a d      - Interactive devpod popup selector"
    display_info "   Ctrl+a D      - Quick connect to main devpod"
    display_info "   Ctrl+a Ctrl+d - Simple text prompt"
}

# ============================================================================
# Main Setup Flow
# ============================================================================

main() {
    echo "🖥️ macOS Work Environment Setup"
    echo "================================"
    echo ""
    
    setup_permissions
    setup_xcode
    install_homebrew_packages
    setup_git
    setup_tmux
    setup_powerline
    setup_zsh
    setup_devpod_automation
    
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "📁 Installed to your laptop:"
    echo "   ~/.tmux.conf         - Tmux with DevPod key bindings"
    echo "   ~/.vimrc             - Vim configuration" 
    echo "   ~/.zsh/rc.d/         - Additional zsh configurations"
    echo "   ~/worksetup/         - Symlink to this git repo"
    echo "   ~/.oh-my-zsh/themes/ - Custom themes"
    echo ""
    echo "💡 Next steps:"
    echo "   1. Restart your terminal or run: source ~/.zshrc"
    echo "   2. In tmux, reload config: Ctrl+a :source-file ~/.tmux.conf"
    echo "   3. Test DevPod automation: Ctrl+a d"
    echo ""
    echo "🔧 Available commands:"
    echo "   dpsplit <devpod> <project>  - Direct DevPod connection"
    echo "   devpod_debug               - View automation debug logs"
    echo ""
    echo "📂 All scripts reference the git repo directly via ~/worksetup/ symlink"
}

# Run main setup
main
