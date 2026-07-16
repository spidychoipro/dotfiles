#!/bin/bash
# WSL Arch Linux initial setup script
# Usage: bash setup.sh

set -e

echo "=== WSL Arch Linux Setup ==="

# Update system
echo "[1/5] Updating system..."
sudo pacman -Syu --noconfirm

# Install essential packages
echo "[2/5] Installing essential packages..."
sudo pacman -S --noconfirm \
  zsh \
  git \
  curl \
  wget \
  base-devel \
  neovim \
  python \
  nodejs \
  npm

# Setup Korean UTF-8 locale
echo "[3/5] Setting up Korean UTF-8 locale..."
sudo sed -i 's/#ko_KR.UTF-8 UTF-8/ko_KR.UTF-8 UTF-8/' /etc/locale.gen
sudo sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
echo "LANG=ko_KR.UTF-8" | sudo tee /etc/locale.conf

# Install zsh plugins
echo "[4/5] Installing zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true

# Copy dotfiles
echo "[5/5] Copying dotfiles..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/../.inputrc" ~/.inputrc 2>/dev/null || true
cp "$SCRIPT_DIR/../.zshrc" ~/.zshrc 2>/dev/null || true

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
fi

echo "=== Setup complete! ==="
echo "Please restart your terminal or run: source ~/.zshrc"
