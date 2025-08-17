# worksetup

My complete setup for work environments - local macOS development and remote DevPods.

## Quick Start

### Local macOS Setup
```bash
git clone https://github.com/jeffbean/worksetup.git
cd worksetup
./setup.sh
```

### What Gets Installed
- **Homebrew packages** - Development tools, tmux, autojump, etc.
- **Zsh + Oh-My-Zsh** - Enhanced shell with custom themes
- **Tmux configuration** - With powerline and DevPod automation key bindings
- **Vim configuration** - Go-focused development setup
- **DevPod automation** - Scripts for seamless remote development

## DevPod Integration

### Environment Variables
Customize your DevPod behavior:
- **`BEAN_INFRA_BASE_PATH`** - Base directory for autojump population
  - Default: `/home/user/go-code/src/code.uber.internal/infra`
- **`BEAN_SEARCH_DEPTH`** - How deep to search for projects  
  - Default: `1` (immediate subdirectories)

**To customize**: Add to your devpod YAML's `env:` section.

### Tmux Automation

**From your laptop in tmux:**
- **`Ctrl+a d`** - Interactive devpod popup selector
- **`Ctrl+a D`** - Quick connect to main devpod (bean infra)
- **`Ctrl+a Ctrl+d`** - Simple text prompt

### DevPod Project Discovery
The setup automatically pre-populates autojump with your project directories from `$BEAN_INFRA_BASE_PATH`.

After devpod creation, `j project-name` will work immediately for all your projects!

### Available Commands
- **`dpsplit bean-claude-re repair-engine`** - Direct script call
- **`devpod_debug`** - View debug logs
- **`j <project>`** - Jump to project (works immediately after setup)

**Note**: All scripts run directly from the git repo via `~/worksetup/` symlink - no file copying needed!

## Repository Structure

```
worksetup/
├── setup.sh                   🚀 Main macOS setup script
├── backup.sh                  💾 Backup helper
├── osx/                       🖥️ macOS-specific files
│   ├── Brewfile              📦 Basic development tools
│   ├── Brewfile.uber         🏢 Uber-specific tools
│   └── devpod/               🤖 DevPod automation scripts
├── devpod/                    ☁️ DevPod configurations
│   ├── *.yaml                📋 DevPod environment configs
│   ├── home/                 🏠 DevPod shell configurations
│   └── flavors/              🎨 Setup scripts (base, claude)
├── templates/                 📄 Configuration templates
└── unfinished/               🚧 Additional configurations
```

## DevPod Flavors

### Base Flavor
- Standard Go development environment
- Git-spice integration
- Autojump pre-population

### Claude Flavor  
- Extends base with Claude Code integration
- MCP agents for AI assistance
- Custom statusline for Claude

## Debugging

Use `devpod_debug` to view consolidated logs from all DevPod automation scripts:
```bash
devpod_debug        # View recent logs
devpod_debug clear  # Clear all logs
```

