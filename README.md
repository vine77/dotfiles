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
way to `*.pre-dotfiles`), and applies macOS defaults on macOS only. It keeps
reminding you about `*.pre-dotfiles` backups on every run until you've folded
in anything worth keeping (machine-local PATH entries, keys) and deleted them.

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

## Day to day

The `dots` command (defined in `zsh/.zshrc`, so it's on every machine):

- `dots update` — pull the latest and re-run bootstrap: installs new Brewfile
  entries and re-stows symlinks. Run this after another machine pushes. Also
  reports drift (packages installed here but missing from this OS's ledger)
  without uninstalling anything.
- `dots push` — publish this machine's auto-committed ledger updates.
- `dots status` / `dots cd` — quick repo status / jump to the repo.

Installing packages needs no command at all: `brew install foo` auto-updates
and commits this OS's Brewfile via the wrapper in `.zshrc`.

## Adding things

- New config: `mkdir <pkg>`, place files with their in-home paths (e.g.
  `<pkg>/.config/foo/bar.toml`), add `<pkg>` to the stow line in
  `bootstrap.sh`, run `stow <pkg>`.
- New package: just `brew install` it — the wrapper updates and commits this
  OS's Brewfile automatically.
