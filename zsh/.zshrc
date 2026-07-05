# Environment — PATH (each line prepends; brew shellenv below ends up first)
[[ -d /opt/homebrew/opt/ruby/bin ]] && export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
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

# Terminal title — show current directory name
update_terminal_cwd() { echo -ne "\033]0;${PWD##*/}\007" }
autoload -U add-zsh-hook
add-zsh-hook chpwd update_terminal_cwd
update_terminal_cwd

# Completions
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
fi
[[ -d "$HOME/.docker/completions" ]] && FPATH="$HOME/.docker/completions:$FPATH"
autoload -Uz compinit && compinit -i
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
command -v lsd &>/dev/null && alias ls="lsd -lA --date '+%Y-%m-%d %H:%M:%S'"

# Aliases — utilities
if command -v pbcopy &>/dev/null; then
  alias copy=pbcopy
elif command -v wl-copy &>/dev/null; then
  alias copy=wl-copy
fi
alias mirror="wget --mirror --no-parent --convert-links --page-requisites --adjust-extension"
alias weather="curl -4 wttr.in/portland"
alias dif='colordiff --width=`tput cols` -y "$@"'
alias wdif="wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m'"
alias untar="tar -zxvf"
alias uuidgen='uuidgen | tr "[:upper:]" "[:lower:]"'
alias python="python3"
alias pip="pip3"
alias collapse="sed '/./,/^$/!d'"
alias generate-cert="openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem"

# Aliases — npm
alias upgrade="npx npm-check-updates --upgrade"
alias server="npx http-server --port 3030 --cors -c-1"

# Aliases — AI
alias ccu="npx -y ccusage@latest"
alias yolo="claude --dangerously-skip-permissions"

# Functions
br() {
  git for-each-ref --sort=committerdate refs/heads/ \
    --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))' \
    --color=always \
  | awk '{$1=$1};1' \
  | cut -c -$COLUMNS
}

gpt() {
  [ -z "$OPENAI_API_KEY" ] && echo "Error: OPENAI_API_KEY not set" && return 1
  local user_message=""
  [ -p /dev/stdin ] && user_message="$(cat -)"
  if [ -n "$1" ]; then
    [ -z "$user_message" ] && user_message="$1" || user_message="${user_message}\n\n$1"
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
  if [[ $exit_code -eq 0 && "$1" =~ ^(install|uninstall|rmtree|tap|untap)$ ]]; then
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
