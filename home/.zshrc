# login to tmux session on marker
if [ $(hostname) = "marker.diff.mx" ]; then
	if which tmux >/dev/null 2>&1; then
	    # if no session is started, start a new session
	    test -z ${TMUX} && (tmux attach -d || tmux)
	fi
fi

# terminal-picture takes an image file as an argument and displays it at
# terminal width with xterm-256-colors
function terminal-picture {
	#echo "terminal: $COLUMNS $LINES"
	WIDTH_HEIGHT=`identify $1 | awk '{ print $3 }' | sed -e 's/x/ /g'`
	#echo "picture: $WIDTH_HEIGHT"
	PIC_WIDTH=`echo $WIDTH_HEIGHT | awk '{ print $1 }'`
	PIC_HEIGHT=`echo $WIDTH_HEIGHT | awk '{ print $2 }'`
	#echo "width: $PIC_WIDTH"
	#echo "height: $PIC_HEIGHT"
	MAX_WIDTH=`expr $COLUMNS / 2 - 2`
	MAX_HEIGHT=`expr $LINES / 2 - 3`
	#echo "max: $MAX_WIDTH x $MAX_HEIGHT"
	PIC_RATIO=`expr $PIC_WIDTH / $PIC_HEIGHT`
	#echo "pic ratio: $PIC_RATIO"
	TERM_RATIO=`expr $COLUMNS / $LINES`
	#echo "term ratio: $TERM_RATIO"
	if [ "$TERM_RATIO" -gt "$PIC_RATIO" ];
	then
		#echo "using height as constraint";
		convert $1 -resize x`expr $LINES - 1` /tmp/terminal-picture.png && img-cat /tmp/terminal-picture.png;
	else
		#echo "using width as constrint";
		convert $1 -resize `expr $COLUMNS / 2 - 2` /tmp/terminal-picture.png && img-cat /tmp/terminal-picture.png;
	fi

}

function lint-with {
	cd $HOME/.homesick/repos/vim
	git checkout $1
	cd -
	cd $HOME/.homesick/repos/spacemacs
	git checkout $1
	cd -
}

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="kolo"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(archlinux git gpg-agent node rsync ssh-agent sudo systemd tmux kubectl mercurial go golang rbenv)

# User configuration

export PATH="$HOME/.bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# if .homesick directory exists, add alias for all status
if [[ -a $HOME/.homesick ]]; then
	alias homesick-status="find ~/.homesick/repos -maxdepth 1 -mindepth 1 -printf '%f\n' -exec homesick status {} \\;"
	alias homesick-commit="find ~/.homesick/repos -maxdepth 1 -mindepth 1 -printf '%f\n' -exec homesick commit {} 'quick update' \\;"
	alias homesick-pull="find ~/.homesick/repos -maxdepth 1 -mindepth 1 -printf '%f\n' -exec homesick pull {} \\;"
	alias homesick-push="find ~/.homesick/repos -maxdepth 1 -mindepth 1 -printf '%f\n' -exec homesick push {} \\;"
fi

export EDITOR='nvim'

# better history completion
# search all the way to the cursor, not just the first word
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward


# powerline
#. $HOME/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh

# NODENV
#export PATH="$HOME/.nodenv/bin:$PATH"
#eval "$(nodenv init -)"

# pyenv with virtualenv
# eval "$(pyenv virtualenv-init -)"

# nvm
export NVM_DIR="/home/diffalot/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# GOLANG
export GOPATH=$HOME/go
export PATH=$PATH:$HOME/build/go/bin:$GOPATH/bin

# GET GEMS PATH
export PATH=$(ruby -e 'print Gem.user_dir')/bin:$PATH

# if secrets file exists, load it
if [[ -a $HOME/.zsh-secrets ]]; then
	source $HOME/.zsh-secrets
fi

# PERL Environment
export PATH="$HOME/.plenv/bin:$PATH"
eval "$(plenv init - zsh)"

function docker-cleanup {
	echo "Removing non-running containers"
	docker ps -a | grep 'hours ago' | awk '{print $1}' | xargs --no-run-if-empty docker rm;
	echo "Removing unnamed images"
	docker rmi $(docker images | grep "^<none>" | awk '{print $3}');
	echo "Removing orphaned Volumes"
	docker volume ls -qf dangling=true | xargs -r docker volume rm
}

# run terminal-picture after nvm is initialized by oh-my-zsh
terminal-picture ~/avatar.png

alias lock-disable="xset s off -dpms; xautolock -disable"
alias lock-enable="xautolock -enable; xset s on +dpms"

alias screen-setup-hdmi-right-portrait-displayport-right="xrandr --auto && xrandr --output HDMI2 --rotate left --pos 2561x0 --output eDP1 --pos 0x480 --output DP1 --pos 4481x480"d
alias screen-setup-hdmi-above="xrandr --auto && xrandr --output HDMI2 --above eDP1"
alias screen-setup-hdmi-right="xrandr --auto && xrandr --auto --Vyoutput eDP1 --left-of HDMI2 --output HDMI2 --rotate normal"
alias screen-setup-hdmi-right-portrait="xrandr --auto && xrandr --output HDMI2 --rotate left --pos 2561x0 --output eDP1 --pos 0x480"

alias screen-setup-displayport-right="xrandr --auto && xrandr --auto --output eDP1 --left-of DP1 --output DP1 --rotate normal"

alias screen-setup-displayport-right-portrait="xrandr --auto && xrandr --output DP1 --rotate left --pos 2561x0 --output eDP1 --pos 0x1280"
alias screen-setup-displayport-right-portrait-hdmi-right="xrandr --auto && xrandr --output DP1 --rotate left --pos 2561x0 --output eDP1 --pos 0x1280 --output HDMI2 --pos 4721x1280"

alias screen-setup-laptop-only="xrandr --auto && xrandr --output DP1 --off --output DP2 --off --output HDMI1 --off --output HDMI2 --off"

alias screen-setup-present="screen-setup-laptop-only; lock-disable"
alias screen-setup-desk="screen-setup-hdmi-right-portrait; lock-enable"

alias fix-history='mv .zsh_history .zsh_history_bad && strings .zsh_history_bad > .zsh_history && fc -R .zsh_history'
alias toolchain-node='npm update -g && npm install -g nodemon http-server browserify webpack webpack-dev-server img-cat babel-eslint eslint eslint-plugin-react js-beautify csscomb tape mocha npm-check-updates npmrc jsdoc cordova tern hostile ot-pretty-json'
alias toolchain-ruby='gem install pws homesick overcommit bundler foreman rubocop'

alias android-emulator="/opt/android-sdk/tools/emulator -netdelay none -netspeed full -avd Nexus_5_API_23_x86 -use-system-libs"

alias spam-filter="pws get diffalot@diff.mx-email 0 && sieve-connect -s diff.mx -u diffalot@diff.mx --remotesieve all_rules --edit"

alias mutt='cd ~/Desktop && mutt && cd -'

alias vim='nvim'

# Rust

source $HOME/.cargo/env

# WINE
export WINEARCH=win32

wine-prefix() {
   export WINEPREFIX="$HOME/.winetricks/$1"
}

wine-goc() {
   cd $WINEPREFIX/drive_c
}

wine-lsp() {
   ls $* $HOME/.winetricks
}

# added by travis gem
[ -f /home/diff/.travis/travis.sh ] && source /home/diff/.travis/travis.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f /home/diff/google-cloud-sdk/path.zsh.inc ]; then
  source '/home/diff/google-cloud-sdk/path.zsh.inc'
fi

# The next line enables shell command completion for gcloud.
if [ -f /home/diff/google-cloud-sdk/completion.zsh.inc ]; then
  source '/home/diff/google-cloud-sdk/completion.zsh.inc'
fi
if [  ]; then source <(kubectl completion zsh); fi
