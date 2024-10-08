#!/bin/sh
set -eu

# sanity check permissions
[ -d "$HOME/.ssh" ] && sudo chown -R $(whoami) $HOME/.ssh || mkdir -p "$HOME/.ssh"


# After downloading Xcode
[ -e "/Applications/Xcode.app" ] && xcode-select --install || echo OK
[ -e "/Applications/Xcode.app" ] && sudo xcodebuild -license || echo OK

[ -d "$HOME/Library/Caches/Homebrew/" ] && sudo chown -R $(whoami) "$HOME/Library/Caches/Homebrew/"
[ -d "$HOME/.cache" ] && sudo chown -R $(whoami) "$HOME/.cache"
[ -d /usr/local/Caskroom ] && sudo chown -R $(whoami) /usr/local/Caskroom
[ -d /usr/local/sbin ] && sudo chown -R $(whoami) /usr/local/sbin
[ -d /usr/local/lib ] && sudo chown -R $(whoami) /usr/local/lib
[ -d /usr/local/lib/dnscrypt-proxy ] && sudo chown -R root:wheel /usr/local/lib/dnscrypt-proxy
[ -d /usr/local/share ] && sudo chown -R $(whoami) /usr/local/share
[ -d /usr/local/Homebrew/Library/Taps/uber/homebrew-alt ] && rm -rf /usr/local/Homebrew/Library/Taps/uber/homebrew-alt
# install brew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

brew analytics off 2>&1 >/dev/null
brew bundle --file=osx/Brewfile
brew bundle --file=osx/Brewfile.uber

[ ! -d ~/.tmux/plugins/tpm ] && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# powerline
python3 -m venv "${HOME}/Virtualenvs/tmux-plugins"
source "${HOME}/Virtualenvs/tmux-plugins/bin/activate"
pip install powerline-status
## end powerline setup


# zsh
# install : todo - dont do this without prompting
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp --backup=numbered templates/zshrc ~/.zshrc
cp --backup=numbered templates/dot_vimrc "${HOME}/.vimrc"
cp --backup=numbered templates/dot_tmux.conf "${HOME}/.tmux.conf"

mkdir -p "${HOME}/.zsh/rc.d"
rsync unfinished/zsh/rc.d/* "${HOME}/.zsh/rc.d"

cp unfinished/bean.zsh-theme ~/.oh-my-zsh/themes

