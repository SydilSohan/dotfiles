# =============================================================================
# DOTFILES .zshrc - Dev Productivity Config (macOS)
# =============================================================================

# -----------------------------------------------------------------------------
# PATH Configuration
# -----------------------------------------------------------------------------
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/dotfiles/scripts"

# Homebrew (Apple Silicon)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

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
alias cat="bat --paging=never"
alias catp="bat"  # with paging

# macOS specific
alias showfiles="defaults write com.apple.finder AppleShowAllFiles YES && killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles NO && killall Finder"

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
alias gob="go build"
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
alias zshrc="cursor ~/.zshrc"
alias gitconfig="cursor ~/.gitconfig"
alias dotfiles="cd ~/dotfiles && cursor ."

# -----------------------------------------------------------------------------
# Project Switcher (fzf-based)
# -----------------------------------------------------------------------------
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

# Kill process by port (macOS version)
killport() {
    local pid=$(lsof -ti:$1)
    if [[ -n "$pid" ]]; then
        kill -9 $pid
        echo "Killed process $pid on port $1"
    else
        echo "No process found on port $1"
    fi
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
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

cht-js() { cht "javascript/$1"; }
cht-ts() { cht "typescript/$1"; }
cht-go() { cht "go/$1"; }
cht-git() { cht "git/$1"; }

# -----------------------------------------------------------------------------
# Prompt (simple but informative)
# -----------------------------------------------------------------------------
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{cyan}%~%f%F{yellow}${vcs_info_msg_0_}%f $ '

# -----------------------------------------------------------------------------
# History Configuration
# -----------------------------------------------------------------------------
HISTSIZE=10000
SAVEHIST=20000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# -----------------------------------------------------------------------------
# Zsh-specific settings
# -----------------------------------------------------------------------------
setopt AUTO_CD              # cd by typing directory name
setopt CORRECT              # command correction
setopt COMPLETE_IN_WORD     # complete from cursor
setopt IGNORE_EOF           # don't exit on Ctrl-D

# Better tab completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# -----------------------------------------------------------------------------
# direnv - auto-load project .envrc files
# -----------------------------------------------------------------------------
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# -----------------------------------------------------------------------------
# fzf - fuzzy finder keybindings (Ctrl+R for history, Ctrl+T for files)
# -----------------------------------------------------------------------------
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
fi

# -----------------------------------------------------------------------------
# Google Cloud SDK
# -----------------------------------------------------------------------------
if [[ -d "$(brew --prefix 2>/dev/null)/share/google-cloud-sdk" ]]; then
    source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi

# kubectl completion
if command -v kubectl &> /dev/null; then
    source <(kubectl completion zsh)
fi

# Kubernetes/GCloud aliases
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgd="kubectl get deployments"
alias kga="kubectl get all"
alias kaf="kubectl apply -f"
alias kdf="kubectl delete -f"
alias kl="kubectl logs"
alias klf="kubectl logs -f"
alias kex="kubectl exec -it"
alias kctx="kubectl config current-context"
alias kns="kubectl config set-context --current --namespace"

# -----------------------------------------------------------------------------
# Load local overrides if exists
# -----------------------------------------------------------------------------
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# -----------------------------------------------------------------------------
# Zsh plugins (loaded last)
# -----------------------------------------------------------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[[ -f "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Android SDK (auto-added by android-setup)
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"

# Android aliases
alias emu="emulator -avd Pixel_7_API_34"
alias emu-list="emulator -list-avds"
alias adb-devices="adb devices"
alias adb-restart="adb kill-server && adb start-server"
export PATH="$HOME/.local/bin:$PATH"
