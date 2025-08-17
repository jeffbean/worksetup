#!/bin/bash
# Shared functions for devpod setup scripts

load_config() {
    # Simple variable-based configuration
    export BEAN_INFRA_BASE_PATH="${BEAN_INFRA_BASE_PATH:-/home/user/go-code/src/code.uber.internal/infra}"
    export BEAN_SEARCH_DEPTH="${BEAN_SEARCH_DEPTH:-1}"
    
    echo "📍 Using autojump path: $BEAN_INFRA_BASE_PATH (depth: $BEAN_SEARCH_DEPTH)"
}

write_profile_config() {
    local flavor="${1:-base}"
    
    # Load current config to get the values
    load_config
    
    # Write complete configuration to system profile
    sudo tee /etc/profile.d/50-bean.sh > /dev/null <<EOF
# DevPod configuration
export BEAN_DEVPOD_FLAVOR="$flavor"
export BEAN_INFRA_BASE_PATH="$BEAN_INFRA_BASE_PATH"
export BEAN_SEARCH_DEPTH="$BEAN_SEARCH_DEPTH"
EOF
    
    sudo chmod 644 /etc/profile.d/50-bean.sh
    echo "   ✅ Configuration written to /etc/profile.d/50-bean.sh"
}

setup_autojump_database() {
    echo "📁 Populating autojump database with infra projects..."
    
    # Add the base path first
    if [ -d "$BEAN_INFRA_BASE_PATH" ]; then
        autojump --add "$BEAN_INFRA_BASE_PATH" 2>/dev/null || true
        
        # Find and add all subdirectories
        find "$BEAN_INFRA_BASE_PATH" -maxdepth "$BEAN_SEARCH_DEPTH" -type d -exec autojump --add {} \; 2>/dev/null || true
        echo "   Base path: $BEAN_INFRA_BASE_PATH (depth: $BEAN_SEARCH_DEPTH)"
    else
        echo "   ⚠️ Base path $BEAN_INFRA_BASE_PATH not found, skipping autojump setup"
    fi

    # Show autojump stats
    echo "📊 Autojump database stats:"
    autojump -s | tail -7 2>/dev/null || echo "   (stats not available)"
}

copy_base_configs() {
    local base_dir="/home/user/bean-worksetup/devpod/home"

    cp "$base_dir/zshrc" /home/user/.zshrc
    cp "$base_dir/devpod.zsh-theme" /home/user/.oh-my-zsh/themes/
    cp "$base_dir/dot.gitconfig" /home/user/.gitconfig
    cp "$base_dir/dot.gitignore" /home/user/.gitignore

    # Install custom MOTD script
    sudo cp "/home/user/bean-worksetup/devpod/flavors/base/motd-devpod" /etc/update-motd.d/50-bean-devpod
    sudo chmod +x /etc/update-motd.d/50-bean-devpod

    # Write complete configuration to profile
    write_profile_config "base"
}

update_base_configs() {
    local base_dir="/home/user/bean-worksetup/devpod/home"

    [ -f "$base_dir/zshrc" ] && cp "$base_dir/zshrc" /home/user/.zshrc
    [ -f "$base_dir/devpod.zsh-theme" ] && cp "$base_dir/devpod.zsh-theme" /home/user/.oh-my-zsh/themes/
    [ -f "$base_dir/dot.gitconfig" ] && cp "$base_dir/dot.gitconfig" /home/user/.gitconfig
    [ -f "$base_dir/dot.gitignore" ] && cp "$base_dir/dot.gitignore" /home/user/.gitignore
    
    # Update custom MOTD script
    if [ -f "/home/user/bean-worksetup/devpod/flavors/base/motd-devpod" ]; then
        sudo cp "/home/user/bean-worksetup/devpod/flavors/base/motd-devpod" /etc/update-motd.d/50-bean-devpod
        sudo chmod +x /etc/update-motd.d/50-bean-devpod
    fi
    
    # Write complete configuration to profile
    write_profile_config "base"
}
