# =============================================================================
# DOTFILES .bashrc - Dev Productivity Config
# =============================================================================

# -----------------------------------------------------------------------------
# PATH Configuration
# -----------------------------------------------------------------------------
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/dotfiles/scripts"

# -----------------------------------------------------------------------------
# Editor
# -----------------------------------------------------------------------------
export EDITOR="cursor"
export VISUAL="cursor"

# -----------------------------------------------------------------------------
# Git Aliases
# -----------------------------------------------------------------------------
alias g="git"
alias gs="git status"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline -20"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# -----------------------------------------------------------------------------
# Navigation Aliases
# -----------------------------------------------------------------------------
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias proj="cd ~/projects"
alias work="cd ~/work"

# -----------------------------------------------------------------------------
# Listing Aliases
# -----------------------------------------------------------------------------
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"

# -----------------------------------------------------------------------------
# Development Aliases
# -----------------------------------------------------------------------------
alias nr="npm run"
alias nrd="npm run dev"
alias nrb="npm run build"
alias nrt="npm run test"
alias ni="npm install"

# Go
alias gr="go run"
alias gb="go build"
alias gt="go test ./..."
alias gmt="go mod tidy"

# Docker
alias d="docker"
alias dc="docker-compose"
alias dps="docker ps"
alias dpsa="docker ps -a"

# -----------------------------------------------------------------------------
# Quick Edit Configs
# -----------------------------------------------------------------------------
alias bashrc="cursor ~/.bashrc"
alias gitconfig="cursor ~/.gitconfig"
alias dotfiles="cd ~/dotfiles && cursor ."

# -----------------------------------------------------------------------------
# Project Switcher (fzf-based)
# -----------------------------------------------------------------------------
# Usage: fp (find project) - fuzzy find and cd to project
fp() {
    local dir
    dir=$(find ~/projects ~/work -maxdepth 2 -type d -name ".git" 2>/dev/null |
          sed 's/\/.git$//' |
          fzf --height 40% --reverse --border)
    if [[ -n "$dir" ]]; then
        cd "$dir"
        echo "Switched to: $dir"
    fi
}

# Open project in Cursor
fpc() {
    local dir
    dir=$(find ~/projects ~/work -maxdepth 2 -type d -name ".git" 2>/dev/null |
          sed 's/\/.git$//' |
          fzf --height 40% --reverse --border)
    if [[ -n "$dir" ]]; then
        cd "$dir"
        cursor .
    fi
}

# -----------------------------------------------------------------------------
# Useful Functions
# -----------------------------------------------------------------------------

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick git add, commit, push
gacp() {
    git add --all
    git commit -m "$1"
    git push
}

# Find process by name
psgrep() {
    ps aux | grep -v grep | grep "$1"
}

# Kill process by port
killport() {
    local pid=$(netstat -ano | grep ":$1" | head -1 | awk '{print $NF}')
    if [[ -n "$pid" ]]; then
        taskkill //F //PID "$pid"
        echo "Killed process $pid on port $1"
    else
        echo "No process found on port $1"
    fi
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    python -m http.server "$port"
}

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# -----------------------------------------------------------------------------
# cht.sh - Quick Reference
# -----------------------------------------------------------------------------
cht() {
    curl -s "cht.sh/$1" | less
}

# Language-specific cheat sheets
cht-js() { cht "javascript/$1"; }
cht-ts() { cht "typescript/$1"; }
cht-go() { cht "go/$1"; }
cht-git() { cht "git/$1"; }

# -----------------------------------------------------------------------------
# Prompt (simple but informative)
# -----------------------------------------------------------------------------
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\[\033[36m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

# -----------------------------------------------------------------------------
# History Configuration
# -----------------------------------------------------------------------------
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# -----------------------------------------------------------------------------
# direnv - auto-load project .envrc files
# -----------------------------------------------------------------------------
if command -v direnv &> /dev/null; then
    eval "$(direnv hook bash)"
fi

# -----------------------------------------------------------------------------
# Load local overrides if exists
# -----------------------------------------------------------------------------
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi

