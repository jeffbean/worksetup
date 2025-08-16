# Claude Code DevPod Setup

Claude Code configurations for DevPod environments.

## Usage

### DevPod Setup
```bash
cp /home/user/bean-worksetup/devpod/claude-devpod.yaml ~/.devpod/claude.devpod.yaml
devpod create --config claude ~/go-code
```

### Manual Setup
```bash
/home/user/bean-worksetup/devpod/flavors/claude/manual-setup.sh
source ~/.zshrc
```

## What it does
- Sets `BEAN_CODE_ENABLED=1` for proper prompt formatting
- Configures Claude statusline with path trimming
- Uses your existing devpod configurations