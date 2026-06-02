# Environment — PATH (first entry wins)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Dotfiles
export DOTFILES_DIR="$HOME/src/dotfiles"

# Terminal title — show current directory name
update_terminal_cwd() { echo -ne "\033]0;${PWD##*/}\007" }
autoload -U add-zsh-hook
add-zsh-hook chpwd update_terminal_cwd
update_terminal_cwd

# Completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  FPATH="$HOME/.docker/completions:$FPATH"
  autoload -Uz compinit && compinit -i
  zmodload -i zsh/complist
fi

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

# Aliases — modern CLI replacements
alias cat=bat
alias cats='bat --paging=never'
alias ls="lsd -lA --date '+%Y-%m-%d %H:%M:%S'"

# Aliases — utilities
alias copy=pbcopy
alias flush="sudo dscacheutil -flushcache"
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

whisper() {
  whisper-cli --no-prints --no-timestamps \
    --model "$(brew --prefix whisper-cpp)/share/whisper-cpp/models/ggml-large-v3-turbo-q5_0.bin" \
    "$@" | sed -E '1{/^$/d;};s/^[[:space:]]+//'
  echo
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

# Brewfile sync — keeps Brewfile in dotfiles up to date
sync_brewfile() {
  command brew bundle dump --file="$DOTFILES_DIR/Brewfile" --force --describe
  (cd "$DOTFILES_DIR" && git add Brewfile && git diff --cached --quiet Brewfile || git commit -m "Update Brewfile")
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

mas() {
  command mas "$@"
  local exit_code=$?
  if [[ $exit_code -eq 0 && "$1" =~ ^(install|uninstall|purchase)$ ]]; then
    echo "Syncing Brewfile..."
    sync_brewfile
  fi
  return $exit_code
}

# Secrets (API keys, database URIs, etc.)
[[ -f ~/.secrets ]] && source ~/.secrets

# Starship prompt
eval "$(starship init zsh)"

# direnv (per-directory env; auto-activates .venv via .envrc)
eval "$(direnv hook zsh)"
