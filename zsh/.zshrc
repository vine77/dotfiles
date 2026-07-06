# Environment — PATH (each line prepends; brew shellenv below ends up first)
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Homebrew — macOS (/opt/homebrew) or Linux (linuxbrew); first found wins
for _brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
  [[ -x $_brew ]] && eval "$($_brew shellenv)" && break
done
unset _brew

# Dotfiles
export DOTFILES_DIR="$HOME/src/dotfiles"

# Per-OS Brewfile ledger — `brew bundle` reads it, sync_brewfile writes it
case "$OSTYPE" in
  darwin*) export HOMEBREW_BUNDLE_FILE="$DOTFILES_DIR/Brewfile.macos" ;;
  linux*)  export HOMEBREW_BUNDLE_FILE="$DOTFILES_DIR/Brewfile.linux" ;;
esac

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_all_dups share_history inc_append_history

# Terminal title — show current directory name (only when stdout is a terminal,
# so piped/captured shells don't get escape codes glued to their output)
update_terminal_cwd() {
  [[ -t 1 ]] || return 0
  echo -ne "\033]0;${PWD##*/}\007"
}
autoload -U add-zsh-hook
add-zsh-hook chpwd update_terminal_cwd
update_terminal_cwd

# Report cwd to VTE terminals via OSC 7 (Ptyxis tab/session restore, new-tab
# inherits directory) — Linux only; macOS Terminal/iTerm don't need it
[[ -r /etc/profile.d/vte-2.91.sh ]] && source /etc/profile.d/vte-2.91.sh

# Completions
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
fi
[[ -d "$HOME/.docker/completions" ]] && FPATH="$HOME/.docker/completions:$FPATH"
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh-24) ]]; then
  compinit -C  # dump is <24h old: skip the security scan (~150ms on slow disks)
else
  compinit -i  # full scan, regenerates the dump
fi               # new completions not showing? rm ~/.zcompdump and reopen
zmodload -i zsh/complist

# Docker compose service name completion
_docker_compose_custom_completion() {
  if [[ $words[1] == "docker" && $words[2] == "compose" ]]; then
    type _docker >/dev/null 2>&1 && _docker
    local cur=${words[CURRENT]}
    if [[ -z "$cur" || "$cur" != -* ]]; then
      local -a services
      services=($(docker compose config --services 2>/dev/null))
      compadd -- "${services[@]}"
    fi
  else
    type _docker >/dev/null 2>&1 && _docker
  fi
}
compdef _docker_compose_custom_completion docker

# Aliases — shortcuts
alias please="sudo"
alias v="vim -O"
alias c=code
alias g=git
alias d=docker
alias reload="source ~/.zshrc"

# Aliases — modern CLI replacements (guarded: only if installed)
if command -v bat &>/dev/null; then
  alias cat='bat'
  alias cats='bat --paging=never'
elif command -v batcat &>/dev/null; then  # Ubuntu's apt names bat's binary batcat
  alias cat='batcat'
  alias cats='batcat --paging=never'
fi
# ls stays unaliased (scripts and agents get plain coreutils output)
if command -v eza &>/dev/null; then
  # default to "." — pathless eza reads filenames from stdin when stdin isn't a TTY
  ll() { eza -la --group-directories-first --git --icons=auto "${@:-.}" }
  lt() { eza --tree --level=2 --icons=auto "${@:-.}" }
else
  alias ll='ls -lAh'
fi

# Aliases — utilities
if command -v pbcopy &>/dev/null; then
  alias copy=pbcopy
elif command -v wl-copy &>/dev/null; then
  alias copy=wl-copy
fi
alias mirror="wget --mirror --no-parent --convert-links --page-requisites --adjust-extension"
alias weather="curl -4 wttr.in/portland"
alias dif='colordiff --width=$(tput cols) -y'
alias wdif="wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m'"
alias untar="tar -xvf"  # tar auto-detects compression on extract (gz/bz2/xz/zst)
alias uuidgen='uuidgen | tr "[:upper:]" "[:lower:]"'
alias python="python3"
alias pip="pip3"
alias generate-cert="openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem"

# Aliases — npm
alias upgrade="npx npm-check-updates --upgrade"
alias server="npx http-server --port 3030 --cors -c-1"

# Aliases — AI
alias ccu="npx -y ccusage@latest"
alias yolo="claude --dangerously-skip-permissions"

# Functions
# thin wrapper over the `git br` alias (.gitconfig) — single source of the format
br() {
  git br --color=always | awk '{$1=$1};1' | cut -c -$(( COLUMNS > 0 ? COLUMNS : 120 ))
}

gpt() {
  [ -z "$OPENAI_API_KEY" ] && echo "Error: OPENAI_API_KEY not set" && return 1
  local user_message=""
  [ -p /dev/stdin ] && user_message="$(cat -)"
  if [ -n "$1" ]; then
    [ -z "$user_message" ] && user_message="$1" || user_message="${user_message}"$'\n\n'"$1"
  fi
  [ -z "$user_message" ] && echo "Error: No message provided" && return 1
  output=$(curl -s "https://api.openai.com/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$(jq -n --arg user_message "$user_message" '{
      model: "gpt-4o",
      messages: [{ role: "user", content: $user_message }]
    }')" | jq -r '.choices[0].message.content')
  [ -n "$output" ] && echo "$output" || (echo "Error" && return 1)
}

npms() { npm start; }

npm-why() {
  if [ -z "$1" ]; then
    echo "Please provide a package name."
    return 1
  fi
  PACKAGE_NAME=$1
  npm why --json "$PACKAGE_NAME" | jq -r '
    .[] |
    select(.name == "'"$PACKAGE_NAME"'") |
    .name + "@" + .version + " from " + (
      if .dependents | length > 0 then
        (.dependents[] | .from.name + "@" + .from.version)
      else
        "root project"
      end
    )
  '
}

skills() { npx skills "$@" --global --yes --agent claude-code; }

# amp [minutes|off|status] — Amphetamine-style: keep laptop awake through
# lid-close/unplug for N minutes (default 10), then normal sleep rules return.
# Survives the invoking SSH session ending (nohup); self-expires as the safety.
amp() {
  local min=${1:-10} pidfile=/tmp/amp-$USER.pid
  case $min in
    status)
      if [[ $OSTYPE == darwin* ]]; then
        pmset -g | grep -i sleepdisabled
      else
        systemd-inhibit --list --no-pager | grep -w amp || echo "amp: no lock active"
      fi
      return ;;
    off)
      [[ -f $pidfile ]] && sudo kill "$(command cat "$pidfile")" 2>/dev/null
      rm -f "$pidfile"
      # always reset on macOS — a stranded disablesleep flag must never survive
      [[ $OSTYPE == darwin* ]] && sudo pmset -a disablesleep 0
      echo "amp: off — normal sleep rules restored"
      return ;;
    <->) ;;
    *)  echo "usage: amp [minutes|off|status]" >&2; return 1 ;;
  esac
  [[ -f $pidfile ]] && amp off >/dev/null
  if [[ $OSTYPE == darwin* ]]; then
    # single root shell owns arm→timer→disarm, so expiry never hits a sudo prompt
    sudo -v || return
    nohup sudo sh -c "pmset -a disablesleep 1; sleep $((min*60)); pmset -a disablesleep 0" \
      >/dev/null 2>&1 & echo $! > "$pidfile"; disown
  else
    # sudo also bypasses polkit denying lid inhibitors to non-local (SSH) sessions
    nohup sudo systemd-inhibit --what=handle-lid-switch:sleep --who=amp \
      --why="amp: awake for $min min" sleep $((min*60)) \
      >/dev/null 2>&1 & echo $! > "$pidfile"; disown
  fi
  echo "amp: awake for $min min through lid close/unplug — 'amp off' to cancel"
}

# Dotfiles management — `dots` for the obvious day-to-day commands
dots() {
  case "${1:-}" in
    update) (cd "$DOTFILES_DIR" && git pull --rebase --autostash && ./bootstrap.sh) ;;
    push)   (cd "$DOTFILES_DIR" && git push) ;;
    status) (cd "$DOTFILES_DIR" && git status -sb) ;;
    cd)     cd "$DOTFILES_DIR" ;;
    ""|help)
            echo "usage: dots update|push|status|cd"
            echo "  update  pull latest and re-run bootstrap (packages + symlinks)"
            echo "  push    publish this machine's ledger commits"
            echo "  status  show repo status"
            echo "  cd      go to the dotfiles repo" ;;
    *)      echo "dots: unknown command '$1'" >&2
            echo "usage: dots update|push|status|cd" >&2
            return 1 ;;
  esac
}

# Brewfile sync — keeps this OS's Brewfile ledger up to date
sync_brewfile() {
  [[ -n "$HOMEBREW_BUNDLE_FILE" ]] || { echo "HOMEBREW_BUNDLE_FILE not set"; return 1 }
  command brew bundle dump --force
  # commit only the ledger (pathspec) so unrelated staged changes never ride along
  (cd "$DOTFILES_DIR" && git add "$HOMEBREW_BUNDLE_FILE" && git diff --cached --quiet -- "$HOMEBREW_BUNDLE_FILE" || git commit -m "Update ${HOMEBREW_BUNDLE_FILE:t}" -- "$HOMEBREW_BUNDLE_FILE")
}

brew() {
  command brew "$@"
  local exit_code=$?
  if [[ $exit_code -eq 0 && "$1" =~ ^(install|reinstall|uninstall|remove|rm|tap|untap)$ ]]; then
    echo "Syncing Brewfile..."
    sync_brewfile
  fi
  return $exit_code
}

# macOS only
if [[ "$OSTYPE" == darwin* ]]; then
  alias flush="sudo dscacheutil -flushcache"

  whisper() {
    whisper-cli --no-prints --no-timestamps \
      --model "$(brew --prefix whisper-cpp)/share/whisper-cpp/models/ggml-large-v3-turbo-q5_0.bin" \
      "$@" | sed -E '1{/^$/d;};s/^[[:space:]]+//'
    echo
  }

  mas() {
    command mas "$@"
    local exit_code=$?
    if [[ $exit_code -eq 0 && "$1" =~ ^(install|uninstall|purchase)$ ]]; then
      echo "Syncing Brewfile..."
      sync_brewfile
    fi
    return $exit_code
  }
fi

# bun (standalone install; on macOS bun comes from brew instead)
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
fi

# Secrets (API keys, database URIs, etc.)
[[ -f ~/.secrets ]] && source ~/.secrets

# Prompt & per-directory env (guarded: only if installed)
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)" 2>/dev/null
