#!/usr/bin/env sh
set -eu

PREFIX="$HOME/.local"
BIN="$PREFIX/bin"
SRC="$PREFIX/src"
mkdir -p "$BIN" "$SRC"
# Note: This only affects the current script's process
export PATH="$BIN:$PATH"

log() { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
die() { printf "\033[1;31m!!\033[0m %s\n" "$*" >&2; exit 1; }

# -----------------------
# Package manager detection
# -----------------------
PKG=""
if command -v apt >/dev/null; then PKG="apt"
elif command -v dnf >/dev/null; then PKG="dnf"
elif command -v pacman >/dev/null; then PKG="pacman"
elif command -v brew >/dev/null; then PKG="brew"
fi

# -----------------------
# Logic Handlers
# -----------------------
echo "Default install mode:"
echo "  1) All system (sudo)"
echo "  2) All local (~/.local)"
echo "  3) Ask per package"
printf "Choice [1/2/3]: "
read -r MODE

case "$MODE" in
  1) DEFAULT_MODE="system" ;;
  2) DEFAULT_MODE="local" ;;
  3) DEFAULT_MODE="ask" ;;
  *) die "Invalid choice" ;;
esac

ask_mode() {
  pkg="$1"
  if [ "$DEFAULT_MODE" != "ask" ]; then
    echo "$DEFAULT_MODE"
    return
  fi

  # Send prompts to stderr so they don't get captured by $(ask_mode)
  echo "Install $pkg via:" >&2
  echo "  1) System (sudo)" >&2
  echo "  2) Local" >&2
  printf "Choice [1/2]: " >&2
  read -r c
  [ "$c" = "1" ] && echo "system" || echo "local"
}

ensure_sudo() {
  sudo -v || die "Sudo authentication failed"
}

# -----------------------
# Editor choice
# -----------------------
echo "Editor to install:"
echo "  1) Vim"
echo "  2) Neovim"
echo "  3) Both"
printf "Choice [1/2/3]: "
read -r EDITOR_CHOICE

INSTALL_VIM=0
INSTALL_NVIM=0

[ "$EDITOR_CHOICE" = "1" ] && INSTALL_VIM=1
[ "$EDITOR_CHOICE" = "2" ] && INSTALL_NVIM=1
[ "$EDITOR_CHOICE" = "3" ] && { INSTALL_VIM=1; INSTALL_NVIM=1; }

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
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | sh
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

install_ack  "$(ask_mode ack)"
install_tmux "$(ask_mode tmux)"
install_npm

log "Bootstrap complete"
log "NOTE: Make sure to add $BIN to your PATH in your .bashrc or .zshrc"
