#!/bin/bash
# =============================================================================
# WSL Native Tools Setup Script
# Called by setup.sh - installs all dev tools natively in WSL
# =============================================================================

set -e

echo "  [WSL] Updating packages..."
sudo apt update -qq

echo "  [WSL] Installing base packages..."
sudo apt install -y -qq zsh curl git fzf build-essential unzip ca-certificates gnupg direnv tmux

# Node.js 22 via NodeSource
if ! command -v node &> /dev/null; then
    echo "  [WSL] Installing Node.js 22..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - >/dev/null 2>&1
    sudo apt install -y -qq nodejs
fi
echo "  [WSL] ✓ Node.js $(node --version)"

# Go
if ! command -v go &> /dev/null; then
    echo "  [WSL] Installing Go..."
    sudo apt install -y -qq golang-go
fi
echo "  [WSL] ✓ $(go version)"

# Verify direnv
command -v direnv &> /dev/null && echo "  [WSL] ✓ direnv $(direnv --version 2>/dev/null | head -n1 || echo 'installed')" || echo "  [WSL] ✗ direnv (failed to install)"

# Verify tmux
command -v tmux &> /dev/null && echo "  [WSL] ✓ tmux $(tmux -V)" || echo "  [WSL] ✗ tmux (failed to install)"

# TypeScript
if ! command -v tsc &> /dev/null; then
    echo "  [WSL] Installing TypeScript..."
    sudo npm install -g typescript >/dev/null 2>&1
fi
echo "  [WSL] ✓ TypeScript $(tsc --version)"

# Claude Code
if ! command -v claude &> /dev/null; then
    echo "  [WSL] Installing Claude Code..."
    sudo npm install -g @anthropic-ai/claude-code >/dev/null 2>&1
fi
echo "  [WSL] ✓ Claude Code"

# GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "  [WSL] Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update -qq 2>/dev/null
    sudo apt install -y -qq gh
fi
echo "  [WSL] ✓ GitHub CLI $(gh --version 2>/dev/null | head -1 | cut -d' ' -f3 || echo 'installed')"

# Docker CLI (use Docker Desktop on Windows with WSL integration)
if ! command -v docker &> /dev/null; then
    echo "  [WSL] Installing Docker CLI..."
    if sudo install -m 0755 -d /etc/apt/keyrings 2>/dev/null && \
       curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null && \
       sudo chmod a+r /etc/apt/keyrings/docker.gpg 2>/dev/null && \
       echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 2>&1; then
        sudo apt update -qq 2>/dev/null
        if sudo apt install -y -qq docker-ce-cli docker-compose-plugin 2>/dev/null; then
            echo "  [WSL] ✓ Docker CLI installed"
        else
            echo "  [WSL] ⚠ Docker CLI installation failed (may need Docker Desktop with WSL integration)"
        fi
    else
        echo "  [WSL] ⚠ Docker repository setup failed (may need Docker Desktop with WSL integration)"
    fi
fi
command -v docker &> /dev/null && echo "  [WSL] ✓ Docker CLI $(docker --version 2>/dev/null | cut -d' ' -f3 | cut -d',' -f1 || echo 'installed')" || echo "  [WSL] ✗ Docker (install Docker Desktop + enable WSL integration)"

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "  [WSL] Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >/dev/null 2>&1
fi
echo "  [WSL] ✓ Oh My Zsh"

# Zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] || git clone --quiet https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] || git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[[ -d "$ZSH_CUSTOM/plugins/zsh-completions" ]] || git clone --quiet https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
echo "  [WSL] ✓ Zsh plugins"

# Set zsh as default shell
if [[ "$SHELL" != *zsh* ]]; then
    sudo chsh -s $(which zsh) $USER 2>/dev/null
    echo "  [WSL] ✓ Set zsh as default shell"
fi

# Get Windows username
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
WIN_HOME="/mnt/c/Users/$WIN_USER"
DOTFILES_DIR="$WIN_HOME/dotfiles"

# Copy .zshrc.wsl from Windows dotfiles
if [[ -f "$DOTFILES_DIR/.zshrc.wsl" ]]; then
    cp "$DOTFILES_DIR/.zshrc.wsl" "$HOME/.zshrc"
    echo "  [WSL] ✓ Copied .zshrc.wsl to ~/.zshrc"
else
    echo "  [WSL] ✗ .zshrc.wsl not found"
fi

# Symlink .gitconfig from Windows dotfiles
if [[ -f "$DOTFILES_DIR/.gitconfig" ]]; then
    rm -f "$HOME/.gitconfig"
    ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    echo "  [WSL] ✓ Linked .gitconfig"
else
    echo "  [WSL] ✗ .gitconfig not found"
fi

# Copy vault password from Windows (if exists)
WIN_VAULT_PASSWORD="/mnt/c/Users/$WIN_USER/.vault_password"
if [[ -f "$WIN_VAULT_PASSWORD" ]]; then
    cp "$WIN_VAULT_PASSWORD" "$HOME/.vault_password"
    chmod 600 "$HOME/.vault_password"
    echo "  [WSL] ✓ Copied vault password"
else
    echo "  [WSL] ⚠ No vault password found at $WIN_VAULT_PASSWORD"
fi

# Authenticate GitHub CLI using encrypted token
TOKEN_FILE="$DOTFILES_DIR/secrets/github/token"
if [[ -f "$TOKEN_FILE" ]] && [[ -f "$HOME/.vault_password" ]]; then
    if ! gh auth status &>/dev/null; then
        echo "  [WSL] Authenticating GitHub CLI..."
        # Decrypt and authenticate
        TOKEN=$("$DOTFILES_DIR/scripts/vault" view "$TOKEN_FILE" 2>/dev/null)
        if [[ -n "$TOKEN" ]]; then
            echo "$TOKEN" | gh auth login --with-token 2>/dev/null
            if gh auth status &>/dev/null; then
                echo "  [WSL] ✓ GitHub CLI authenticated"
            else
                echo "  [WSL] ⚠ GitHub authentication failed"
            fi
        else
            echo "  [WSL] ⚠ Could not decrypt GitHub token"
        fi
    else
        echo "  [WSL] ✓ GitHub CLI already authenticated"
    fi
else
    echo "  [WSL] ⚠ GitHub token or vault password not found - run 'gh-auth setup' after setup"
fi

echo ""
echo "  [WSL] ✓ Setup complete!"
