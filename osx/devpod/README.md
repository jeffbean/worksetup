# DevPod Automation Scripts

Scripts for automating DevPod tmux workflows on macOS.

## Scripts

### `devpod-split.sh`
Main automation script that creates tmux layouts for DevPod development.
- Creates named windows and panes
- SSH to devpods with `ussh`
- Auto-jumps to project directories
- Intelligent session reuse

### `devpod-selector.sh`
Interactive popup for selecting DevPods visually.
- Shows running/stopped status with color indicators
- Numbered menu selection
- Prompts for project name

### `debug-devpod.sh`
Debug log viewer for troubleshooting automation issues.
- Consolidated logging from all devpod scripts
- View recent activity and errors

## Installation

These scripts are automatically installed by `../setup.sh` to `~/worksetup/` with proper permissions and shell aliases.

## Tmux Key Bindings

After setup, these key bindings are available in tmux:
- `Ctrl+a d` - Interactive devpod popup selector
- `Ctrl+a D` - Quick connect to main devpod (bean infra)
- `Ctrl+a Ctrl+d` - Simple text prompt (fallback)

## Dependencies

- `tmux` - Terminal multiplexer
- `jq` - JSON processing (for some internal parsing)
- `devpod` - Uber's devpod CLI tool
- `ussh` - Uber's SSH tool
- `autojump` - Directory navigation
