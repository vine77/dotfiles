# Colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Auto-complete
[ -f `brew --prefix`/etc/bash_completion ] && . `brew --prefix`/etc/bash_completion
[[ -s "$HOME/.qfc/bin/qfc.sh" ]] && source "$HOME/.qfc/bin/qfc.sh"

# Add git to prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[$(tput bold)\]\W\[$(tput setaf 2)\]$(__git_ps1)\[$(tput setaf 7)\] \$ \[$(tput sgr0)\]'

# Bash
export BASH_SILENCE_DEPRECATION_WARNING=1

# Aliases
eval "$(hub alias -s)"  # Alias git to hub
alias ed="node debug node_modules/ember-cli/bin/ember"
alias v="vim -O"
alias c=code
alias p=puppet
alias g=git
alias l=less
alias d=docker
alias watch="ember build --watch"
alias pg_start="pg_ctl start -l /usr/local/var/log/postgresql -D /usr/local/var/postgres"
alias pg_stop="launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist; pg_ctl stop -m fast -D /usr/local/var/postgres"
alias flush="sudo dscacheutil -flushcache"
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias mirror="wget --mirror --no-parent --convert-links --page-requisites --adjust-extension"
alias nuke="rm -rf bower_components node_modules tmp dist && npm cache clean && bower cache clean && npm install && bower install"
alias exit_code="echo $?"
alias weather="curl -4 wttr.in/portland"
alias copy=pbcopy
alias todo=task
alias todos=task
alias tasks=task
alias lorem="lorem-ipsum --units paragraphs --count 5 | fold -s | vim -"
alias blinken="/Users/nathan/repos/keyboard-leds/keyboard_leds -c1"
alias blinkoff="/Users/nathan/repos/keyboard-leds/keyboard_leds -c0"
alias dif='colordiff --width=`tput cols` -y "$@"'
alias wdif="wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m'"
alias google="surfraw -browser='lynx -accept_all_cookies' google"
alias setemail="for d in *; do [ -d \"${d}\" ] && (cd $d && git config user.email nathan.ward@puppet.com); done"
alias chrome="open -a /Applications/Google\ Chrome.app --args --incognito"
alias untar="tar -zxvf"
alias hist="HISTTIMEFORMAT=\"%y-%m-%d %T \" history"
alias nvm-lts="nvm install lts/* --latest-npm ----reinstall-packages-from=node && nvm alias default lts/*"
alias nvm-latest="nvm install node --latest-npm ----reinstall-packages-from=node && nvm alias default node"
alias cra=create-react-app
alias kc=kubectl
alias unmount="diskutil unmount /dev/disk3"
alias upgrade="npx npm-check-updates --upgrade"
alias server="echo 'Local server at http://localhost:5000' && python3 -m http.server 5000"
# alias server="npx http-server --port 5000 --cors --ssl"
alias whereami="pwd"
alias cat="bat"
alias generate-cert="openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem"

# Relay
alias relay-api-docs="cd ~/src/relay-api/ && npx -p yamljs yaml2json openapi/latest.yaml > openapi/swagger.json && echo 'Serving Swagger UI at http://localhost:8080' && docker run -p 8080:8080 -e SWAGGER_JSON=/mnt/swagger.json -v `pwd`/openapi:/mnt swaggerapi/swagger-ui"
alias openapi="echo 'Serving ReDoc at http://localhost:8080' && docker run -it --rm -p 8080:80 -v ~/src/relay-api/openapi/latest.yaml:/usr/share/nginx/html/latest.yaml -e SPEC_URL=latest.yaml redocly/redoc"
alias relay-mock-server="docker run -p 8000:8000 -v /Users/ward/src/relay-api/openapi/latest.yaml:/api.yaml gcr.io/nebula-contrib/apisprout /api.yaml"
export GO111MODULE="on"

function findfile() {
  find . -not -path './tmp/*' -and -not -path './dist/*' -and -not -path './vendor/*' -and -not -path './node_modules/*' -and -not -path './bower_components/*' -and -name $@
}

function ll() {
  if [ $# -eq 0 ]; then
    ls -laG
  elif [ -f $1 ]; then
    ls -laG $(dirname $1)
  else
    ls -laG $@
  fi
}

function running() {
  if ps aux | grep -v "grep" | grep $1 &> /dev/null; then
    echo Yes $1 is running
  else
    echo No $1 is not running
    return 1
  fi
}

function e() {
  if [ $# -eq 0 ]; then
    ember
  elif [ "$1" == "t" ] && [ "$2" == "p" ]; then
    ember test --server --launch=phantomjs
  else
    ember "$@"
  fi
}

function suchGit() {
  if [ $1 = "stash" ]; then
    git stash;
  elif [ $1 = "pop" ]; then
    git stash pop;
  elif [ $1 = "fetch" ]; then
    if [ -z "$2" ]; then
      git fetch origin 2017.2.x;
    else
      git fetch origin $2;
    fi
  elif [ $1 = "reset" ]; then
    if [ -z "$2" ]; then
      git reset --hard FETCH_HEAD;
    else
      git reset --hard $2;
    fi
  elif [ $1 = "base" ]; then
    if [ -z "$2" ]; then
      git rebase -i HEAD^;
    else
      git rebase -i HEAD~$2;
    fi
  elif [ $1 = "log" ]; then
    glg;
  else
    git "$@"
  fi
}
alias wow="git status"
alias such=suchGit
alias much=suchGit
alias very=suchGit
alias many=suchGit
alias so=suchGit

function findstring() {
  ag $(ag $1 | grep -E '[0-9]+:' | grep -Eo -1 '"([^"]+)"' | head -1 | grep -Eo '[^"]+');
}

function tre() {
  if [ -f .gitignore ]; then
    tree -L 2 -I `cat .gitignore | grep "^[^#]" | sed "s/\///g" | paste -sd "|" -`
  else
    tree -L 2
  fi
}

# iTerm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Default editor
export EDITOR=vim

# npm
export NO_UPDATE_NOTIFIER=true

# Set ag as the default source for fzf
export FZF_DEFAULT_COMMAND='ag -g ""'

# CLI Browser
# export BROWSER=lynx

# Postgres
export PGDATA=/usr/local/var/postgres

# Path
export PATH="~/bin:$PATH"
export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"  # PATH for Python 2.7
export GOPATH=~/go
export PATH="$GOPATH/bin:$PATH"
export ANDROID_HOME="/usr/local/opt/android-sdk"  # Path for the Android SDK
export PATH="/Applications/Sketch.app/Contents/Resources/sketchtool/bin:$PATH"  # SketchTool
export HTTPS=true

# Docker
alias dl='docker ps -lq'
alias dc="docker exec -it $(docker ps -lq) bash"
# alias pcd="docker run -P -it -v ~/cloud-discovery/data:/data -v ~/.ssh:/root/.ssh -v ~/cloud-discovery/credentials:/credentials gcr.io/hafjell-159619/cloud-discovery"
alias pcd="docker run -v ~/cloud-discovery/data:/data -v ~/.ssh:/root/.ssh -v ~/cloud-discovery:/credentials -p 9999:9999 gcr.io/hafjell-159619/cloud-discovery:latest"
alias pcd-update="docker pull gcr.io/hafjell-159619/cloud-discovery:latest"
alias pcd-kill="docker kill $(dl)"
alias pcd-live="docker run -P -it -v ~/cloud-discovery/data:/data -v ~/.ssh:/root/.ssh -v ~/cloud-discovery/credentials:/credentials -v ~/cloud-discovery/public:/usr/src/app/resources/public -P gcr.io/hafjell-159619/cloud-discovery"

# Google Cloud SDK gcloud
source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc
source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# GPG key
export GPG_TTY=$(tty)

# added by travis gem
[ -f /Users/ward/.travis/travis.sh ] && source /Users/ward/.travis/travis.sh

# Docker
docker-kill() { docker kill $(docker ps -q); }
docker-rm() { docker rm $(docker ps -a -q); }
docker-rmi() { docker rmi $(docker images -q); }

