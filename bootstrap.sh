#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$HOME/src/dotfiles"
cd "$DOTFILES_DIR"

# Homebrew — install if missing, then load into this shell
if ! command -v brew &>/dev/null && [[ ! -x /opt/homebrew/bin/brew && ! -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
for brew_path in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
  if [[ -x "$brew_path" ]]; then
    eval "$("$brew_path" shellenv)"
    break
  fi
done

# Per-OS Brewfile ledger (same selection as zsh/.zshrc)
case "$OSTYPE" in
  darwin*) export HOMEBREW_BUNDLE_FILE="$DOTFILES_DIR/Brewfile.macos" ;;
  *)       export HOMEBREW_BUNDLE_FILE="$DOTFILES_DIR/Brewfile.linux" ;;
esac

# Packages & apps
echo "==> Installing from ${HOMEBREW_BUNDLE_FILE##*/}..."
brew bundle

# Stow dotfiles — move aside any real files that would block linking
echo "==> Linking dotfiles..."
for f in "$HOME/.zshrc" "$HOME/.gitconfig" "$HOME/.gitignore_global"; do
  [[ -e "$f" || -L "$f" ]] || continue
  # leave stow's own links (relative, into this repo); move anything else aside
  if [[ "$(readlink "$f" 2>/dev/null || true)" != src/dotfiles/* ]]; then
    echo "    moving existing $f to $f.pre-dotfiles"
    mv "$f" "$f.pre-dotfiles"
  fi
done
stow -v -R --target="$HOME" git zsh

# macOS defaults
if [[ "$OSTYPE" == darwin* ]]; then
  echo "==> Applying macOS defaults..."
  source "$DOTFILES_DIR/macos-defaults.sh"
fi

echo "==> Done! Restart your terminal (or run: source ~/.zshrc)"
