#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$HOME/src/dotfiles"

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Packages & apps
echo "==> Installing from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# Stow dotfiles
echo "==> Linking dotfiles..."
cd "$DOTFILES_DIR"
stow -v --target="$HOME" git zsh

# macOS defaults
echo "==> Applying macOS defaults..."
source "$DOTFILES_DIR/macos-defaults.sh"

echo "==> Done! Restart your terminal (or run: source ~/.zshrc)"
