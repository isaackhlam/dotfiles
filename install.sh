#!/usr/bin/env sh
set -eu

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

PREFIX="$HOME/.local"
BIN="$PREFIX/bin"
SRC="$PREFIX/src"
mkdir -p "$BIN" "$SRC"
export PATH="$BIN:$PATH"

log() { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
die() { printf "\033[1;31m!!\033[0m %s\n" "$*" >&2; exit 1; }
timestamp() { date +"%Y%m%d-%H%M%S"; }

link() {
    src="$1"
    dst="$2"

    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        log "$dst is already correctly linked."
        return
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        # Using ask_yn logic here for consistency
        if ask_yn "$dst exists. Overwrite with backup?" n; then
            bak="$dst.bak.$(timestamp)"
            mv "$dst" "$bak"
            log "Backed up $dst → $bak"
        else
            log "Skipped $dst"
            return
        fi
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    log "Linked $dst → $src"
}

# ----------------
# Config Installer
# ----------------
install_config_nvim() {
  link "$DOTFILES_DIR/nvim" "$XDG_CONFIG_HOME/nvim"
}

install_config_tmux() {
  link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
}

install_config_alacritty() {
  link "$DOTFILES_DIR/alacritty" "$XDG_CONFIG_HOME/alacritty"
}

install_config_btop() {
  link "$DOTFILES_DIR/btop" "$XDG_CONFIG_HOME/btop"
}



# -----------------------
# Logic Handlers
# -----------------------

ask_yn() {
  prompt="$1"
  default="$2"

  while :; do
      [ "$default" = "y" ] && p="[Y/n]" || p="[y/N]"
      printf "%s %s: " "$prompt" "$p" >&2
      read -r ans
      [ -z "$ans" ] && ans="$default"
      case "$ans" in
          y|Y) return 0 ;;
          n|N) return 1 ;;
          *) echo "Please answer y or n." >&2 ;;
      esac
  done
}

ask_choice() {
  prompt="$1"
  choices="$2"
  default="$3"

  while :; do
    printf "%s\nChoose [%s]: " "$prompt" "$default" >&2
    read -r ans
    [ -z "$ans" ] && ans="$default"

    for c in $choices; do
        if [ "$ans" = "$c" ]; then echo "$ans"; return; fi
    done
    echo "Invalid choice. Valid options: $choices" >&2
  done
}

ask_mode() {
  pkg="$1"
    [ "$DEFAULT_MODE" != "ask" ] && { echo "$DEFAULT_MODE"; return; }
    ask_choice "Install $pkg via: 1) System, 2) Local" "1 2" "2" | sed 's/1/system/;s/2/local/'
}


ensure_sudo() {
  sudo -v || die "Sudo authentication failed"
}

# -----------------------
# Main Setup
# -----------------------

PKG=""
if command -v apt >/dev/null; then PKG="apt"
elif command -v dnf >/dev/null; then PKG="dnf"
elif command -v pacman >/dev/null; then PKG="pacman"
elif command -v brew >/dev/null; then PKG="brew"
fi

# 1. Global Mode
MODE_CHOICE="$(ask_choice "Default install mode:
1) All system (sudo)
2) All local (~/.local)
3) Ask per package" "1 2 3" "1")"

case "$MODE_CHOICE" in
    1) DEFAULT_MODE="system" ;;
    2) DEFAULT_MODE="local" ;;
    3) DEFAULT_MODE="ask" ;;
esac

# 2. Editor Selection
EDITOR_CHOICE="$(ask_choice "Editor to install:
1) Vim
2) Neovim
3) Both
4) None" "1 2 3 4" "2")"

INSTALL_VIM=0; INSTALL_NVIM=0
[ "$EDITOR_CHOICE" = "1" ] && INSTALL_VIM=1
[ "$EDITOR_CHOICE" = "2" ] && INSTALL_NVIM=1
[ "$EDITOR_CHOICE" = "3" ] && { INSTALL_VIM=1; INSTALL_NVIM=1; }

# 3. Optional Tools
INSTALL_ACK=0
if ask_yn "Install ack for fuzzy finding?" y; then
    INSTALL_ACK=1
fi

# -----------------------
# Install Functions
# -----------------------

install_vim() {
  mode="$1"
  log "Installing Vim ($mode)"

  if [ "$mode" = "system" ]; then
    [ -z "$PKG" ] && die "No package manager found for system install"
    ensure_sudo
    case "$PKG" in
      apt) sudo apt install -y vim ;;
      dnf) sudo dnf install -y vim ;;
      pacman) sudo pacman -S --noconfirm vim ;;
      brew) brew install vim ;;
    esac
  else
    cd "$SRC"
    [ -d vim ] || git clone --depth 1 https://github.com/vim/vim.git
    cd vim && git pull
    ./configure --prefix="$PREFIX"
    make -j$(getconf _NPROCESSORS_ONLN)
    make install
  fi

  # Install vim-plug
  mkdir -p "$HOME/.vim/autoload"
  curl -fsSL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    -o "$HOME/.vim/autoload/plug.vim"
}

install_nvim() {
  mode="$1"
  log "Installing Neovim ($mode)"

  if [ "$mode" = "system" ]; then
    ensure_sudo
    case "$PKG" in
      apt) sudo apt install -y neovim ;;
      dnf) sudo dnf install -y neovim ;;
      pacman) sudo pacman -S --noconfirm neovim ;;
      brew) brew install neovim ;;
    esac
  else
    cd "$SRC"
    [ -d neovim ] || git clone --depth 1 https://github.com/neovim/neovim.git
    cd neovim && git pull
    # Neovim build usually requires cmake
    make CMAKE_BUILD_TYPE=Release
    make install PREFIX="$PREFIX"
  fi

  mkdir -p "$HOME/.local/share/nvim/site/autoload"
  curl -fsSL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    -o "$HOME/.local/share/nvim/site/autoload/plug.vim"
}

# # -----------------------
# ack
# -----------------------

install_ack() {
  mode="$1"
  log "Installing ack ($mode)"

  if [ "$mode" = "system" ]; then
    ensure_sudo
    case "$PKG" in
      apt|dnf) sudo $PKG install -y ack ;;
      pacman) sudo pacman -S --noconfirm ack ;;
      brew) brew install ack ;;
    esac
  else
    curl -fsSL https://beyondgrep.com/ack-v3.7.0 > "$BIN/ack"
    chmod +x "$BIN/ack"
  fi
}

# -----------------------
# npm (nvm)
# -----------------------
install_npm() {
  log "Installing npm (nvm)"
  (
    unset PREFIX
    if [ ! -d "$HOME/.nvm" ]; then
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi
    # shellcheck disable=SC1090
    . "$HOME/.nvm/nvm.sh"
    nvm install --lts
  )
}



# -----------------------
# tmux + tpm
# -----------------------
install_tmux() {
  mode="$1"
  log "Installing tmux ($mode)"

  if [ "$mode" = "system" ]; then
    ensure_sudo
    case "$PKG" in
      apt|dnf) sudo $PKG install -y tmux ;;
      pacman) sudo pacman -S --noconfirm tmux ;;
      brew) brew install tmux ;;
    esac
  else
    cd "$SRC"
    [ -d tmux ] || git clone https://github.com/tmux/tmux.git
    cd tmux && git pull
    sh autogen.sh
    ./configure --prefix="$PREFIX"
    make && make install
  fi

  install_tpm
}

install_tpm() {
  log "Installing tpm"
  TPM="$HOME/.tmux/plugins/tpm"
  [ -d "$TPM" ] || git clone https://github.com/tmux-plugins/tpm "$TPM"
}

# -----------------------
# Run installs
# -----------------------
[ "$INSTALL_VIM" -eq 1 ]  && install_vim  "$(ask_mode vim)"
[ "$INSTALL_NVIM" -eq 1 ] && install_nvim "$(ask_mode neovim)"
[ "$INSTALL_ACK" -eq 1 ] && install_ack "$(ask_mode ack)"
install_tmux "$(ask_mode tmux)"
install_npm

[ "$INSTALL_NVIM" -eq 1 ] && install_config_nvim
install_config_tmux
install_config_alacritty
install_config_btop

log "Bootstrap complete"
log "NOTE: Make sure to add $BIN to your PATH in your .bashrc or .zshrc"

