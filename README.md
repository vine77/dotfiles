# dotfiles

Cross-platform dotfiles for macOS and Linux: GNU Stow symlink packages plus a
per-OS Homebrew bundle.

## Setup

```sh
git clone https://github.com/vine77/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles && ./bootstrap.sh
```

`bootstrap.sh` is idempotent: it installs Homebrew if missing, installs this
OS's Brewfile, symlinks the stow packages (backing up any real files in the
way to `*.pre-dotfiles`), and applies macOS defaults on macOS only.

## Layout

- `zsh/`, `git/` — stow packages, symlinked into `$HOME`. One `.zshrc` serves
  both OSes: shared config is unconditional, tool-specific bits are guarded
  with `command -v`, and macOS-only pieces live in one `$OSTYPE` block.
- `Brewfile.macos`, `Brewfile.linux` — per-OS package ledgers. `.zshrc` points
  `HOMEBREW_BUNDLE_FILE` at this OS's file, so bare `brew bundle` and
  `brew bundle dump` read/write the right one. Each machine only ever dumps to
  its own ledger, so the `brew()` auto-sync wrapper (which dumps and commits
  after installs/uninstalls) is safe on every platform. A new platform is just
  one more `Brewfile.<os>`.
- `bootstrap.sh` — one-command setup, safe to re-run.
- `macos-defaults.sh` — macOS system preferences.

## Adding things

- New config: `mkdir <pkg>`, place files with their in-home paths (e.g.
  `<pkg>/.config/foo/bar.toml`), add `<pkg>` to the stow line in
  `bootstrap.sh`, run `stow <pkg>`.
- New package: just `brew install` it — the wrapper updates and commits this
  OS's Brewfile automatically.
