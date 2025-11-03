#!/usr/bin/env zsh
# =============================================================================
# .zshrc - ZSH Configuration for Ubuntu
# Migrated from macOS dotfiles
# =============================================================================

# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
export DOTFILES_PATH="$HOME/.dotfiles/ubuntu"
export EDITOR="vim"
export VISUAL="vim"

# ------------------------------------------------------------------------------
# Path Configuration - Adapted for Ubuntu
# The higher it is, the more priority it has
# ------------------------------------------------------------------------------
path=(
	"$HOME/bin"
	"$HOME/.local/bin"
	"$JAVA_HOME/bin"
	"$GEM_HOME/bin"
	"$GOPATH/bin"
	"$HOME/.cargo/bin"
	"/usr/local/bin"
	"/usr/bin"
	"/bin"
	"/usr/local/sbin"
	"/usr/sbin"
	"/sbin"
	"$path"
)

export path

# ------------------------------------------------------------------------------
# History Configuration
# ------------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# ------------------------------------------------------------------------------
# ZSH Options
# ------------------------------------------------------------------------------
setopt AUTO_CD              # cd by typing directory name if it's not a command
setopt AUTO_PUSHD           # Make cd push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS    # Don't push multiple copies of the same directory
setopt CORRECT              # Spelling correction
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shells

# ------------------------------------------------------------------------------
# Completion System
# ------------------------------------------------------------------------------
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------
# Enable aliases to be sudo'ed
alias sudo='sudo '

# Directory Navigation
alias ..="cd .."
alias ...="cd ../.."

# Ls aliases - Check if eza is installed, fallback to ls
if command -v eza &> /dev/null; then
	alias ls="eza --icons --git"
	alias l="eza -l --icons --git -a"
	alias lt="eza --tree --level=2 --long --icons --git"
	alias ltree="eza --tree --level=2 --icons --git"
else
	alias ls="ls --color=auto"
	alias l="ls -lah"
	alias lt="ls -lhR"
	alias ltree="tree -L 2"
fi

# Dotfiles
alias dotfiles='cd $DOTFILES_PATH'

# Git aliases
alias gadd="git add"
alias gc='git commit -m'
alias gca="git add --all && git commit --amend --no-edit"
alias gco="git checkout"
alias gdiff='git diff'
alias gst="git status"
alias gps="git push"
alias gpl="git pull"
alias gb="git branch"
alias gl='git log'

# Utils
alias k='kill -9'
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias remove='sudo apt remove'

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
# Create a directory and cd into it
mkcd() {
	mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
	if [ -f "$1" ]; then
		case "$1" in
			*.tar.bz2)   tar xjf "$1"     ;;
			*.tar.gz)    tar xzf "$1"     ;;
			*.bz2)       bunzip2 "$1"     ;;
			*.rar)       unrar x "$1"     ;;
			*.gz)        gunzip "$1"      ;;
			*.tar)       tar xf "$1"      ;;
			*.tbz2)      tar xjf "$1"     ;;
			*.tgz)       tar xzf "$1"     ;;
			*.zip)       unzip "$1"       ;;
			*.Z)         uncompress "$1"  ;;
			*.7z)        7z x "$1"        ;;
			*)           echo "'$1' cannot be extracted via extract()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# ------------------------------------------------------------------------------
# Starship Prompt
# ------------------------------------------------------------------------------
if command -v starship &> /dev/null; then
	eval "$(starship init zsh)"
else
	# Fallback prompt if starship is not installed
	PROMPT='%F{green}➜%f %F{cyan}%~%f '
fi

# ------------------------------------------------------------------------------
# Additional Tool Integrations
# ------------------------------------------------------------------------------
# fzf - Fuzzy finder (if installed)
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
	source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
	source /usr/share/doc/fzf/examples/completion.zsh
fi

# zoxide - Smarter cd command (if installed)
if command -v zoxide &> /dev/null; then
	eval "$(zoxide init zsh)"
fi

# ------------------------------------------------------------------------------
# Welcome Message
# ------------------------------------------------------------------------------
# Uncomment to show system info on terminal start
# if command -v neofetch &> /dev/null; then
#     neofetch
# fi
