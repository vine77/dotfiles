# Colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Auto-complete
[ -f `brew --prefix`/etc/bash_completion ] && . `brew --prefix`/etc/bash_completion
[[ -s "$HOME/.qfc/bin/qfc.sh" ]] && source "$HOME/.qfc/bin/qfc.sh"

# Add git to prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[$(tput bold)\]\W\[$(tput setaf 2)\]$(__git_ps1)\[$(tput setaf 7)\] \$ \[$(tput sgr0)\]'

# Aliases
alias git=hub
alias such=hub
alias very=hub
alias wow="hub status"
alias ed="node debug node_modules/ember-cli/bin/ember"
alias v="vim -O"
alias a=atom
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
alias server="python -m SimpleHTTPServer"
alias nuke="rm -rf bower_components node_modules tmp dist && npm cache clean && bower cache clean && npm install && bower install"
alias code="echo $?"
alias weather="curl -4 wttr.in/portland"
alias copy=pbcopy
alias todo=task
alias todos=task
alias tasks=task
alias tre='tree -L 2 -I `cat .gitignore | grep "^[^#]" | sed "s/\///g" | paste -sd "|" -`'
alias lorem="lorem-ipsum --units paragraphs --count 5 | fold -s | vim -"
alias blinken="/Users/nathan/repos/keyboard-leds/keyboard_leds -c1"
alias blinkoff="/Users/nathan/repos/keyboard-leds/keyboard_leds -c0"
alias dif='colordiff --width=`tput cols` -y "$@"'
alias wdif="wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m'"
alias google="surfraw -browser='lynx -accept_all_cookies' google"
alias pelogin="curl -v -k -D cookies.txt -d 'username=admin&password=puppetlabs&rememberMe=true' https://pecouch-latest.eng.puppetlabs.net/auth/login"
alias setemail="for d in *; do [ -d \"${d}\" ] && (cd $d && git config user.email nathan.ward@puppet.com); done"
alias chrome="open -a /Applications/Google\ Chrome.app --args --incognito"
alias untar="tar -zxvf"
alias hist="HISTTIMEFORMAT=\"%y-%m-%d %T \" history"
alias upgradenode="nvm install node --reinstall-packages-from=node"
alias cra=create-react-app

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

# iTerm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Default editor
export EDITOR=vim

# Set ag as the default source for fzf
export FZF_DEFAULT_COMMAND='ag -g ""'

# CLI Browser
# export BROWSER=lynx

# Postgres
export PGDATA=/usr/local/var/postgres

# Path
export PATH="~/bin:$PATH"
export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"  # PATH for Python 2.7
export VAGRANT_CWD="/Users/nathan/vms/centos7"
export ANDROID_HOME="/usr/local/opt/android-sdk"  # Path for the Android SDK

# Node
export PATH="$PATH:$(yarn global bin)"

# Docker
alias dl='docker ps -lq'
alias dc="docker exec -it $(docker ps -lq) bash"
# alias pcd="docker run -P -it -v ~/cloud-discovery/data:/data -v ~/.ssh:/root/.ssh -v ~/cloud-discovery/credentials:/credentials gcr.io/hafjell-159619/cloud-discovery"
alias pcd="docker run -v ~/cloud-discovery/data:/data -v ~/.ssh:/root/.ssh -v ~/cloud-discovery:/credentials -p 9999:9999 gcr.io/hafjell-159619/cloud-discovery:latest"
alias pcd-update="docker pull gcr.io/hafjell-159619/cloud-discovery:latest"
alias pcd-kill="docker kill $(dl)"
alias pcd-live="docker run -P -it -v ~/cloud-discovery/data:/data -v ~/.ssh:/root/.ssh -v ~/cloud-discovery/credentials:/credentials -v ~/cloud-discovery/public:/usr/src/app/resources/public -P gcr.io/hafjell-159619/cloud-discovery"
