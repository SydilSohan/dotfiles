#!/bin/bash
# =============================================================================
# Dotfiles Bootstrap Script (Cross-Platform: macOS + Windows)
# =============================================================================
# Idempotent: Safe to run multiple times, always produces same result
# Usage: ./setup.sh
# =============================================================================

set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$MINGW_PREFIX" ]]; then
    OS="windows"
else
    OS="linux"
fi

echo "=================================================="
echo "  Dotfiles Setup Script"
echo "  Detected OS: $OS"
echo "=================================================="
echo ""

backup_if_exists() {
    if [ -f "$1" ] || [ -L "$1" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "  Backing up $1"
        mv "$1" "$BACKUP_DIR/"
    fi
}

create_symlinks() {
    echo "[1/5] Creating symlinks..."
    backup_if_exists "$HOME/.gitconfig"
    ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

    if [[ "$OS" == "macos" ]]; then
        backup_if_exists "$HOME/.zshrc"
        ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
        echo "  ✓ Linked .zshrc and .gitconfig"
    else
        backup_if_exists "$HOME/.bashrc"
        ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
        echo "  ✓ Linked .bashrc and .gitconfig"
    fi
}

install_host_tools() {
    echo ""
    echo "[2/5] Installing host tools..."

    if [[ "$OS" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            echo "  Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            [[ -f "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        echo "  ✓ Homebrew"

        command -v fzf &> /dev/null || brew install fzf
        command -v tmux &> /dev/null || brew install tmux
        command -v direnv &> /dev/null || brew install direnv
        command -v bat &> /dev/null || brew install bat
        command -v node &> /dev/null || brew install node
        command -v go &> /dev/null || brew install go
        command -v gh &> /dev/null || brew install gh
        echo "  ✓ fzf, tmux, direnv, bat, node, go, gh"

        if command -v node &> /dev/null; then
            command -v tsc &> /dev/null || npm install -g typescript
            command -v claude &> /dev/null || npm install -g @anthropic-ai/claude-code
            echo "  ✓ TypeScript, Claude Code"
        fi

        # Google Cloud SDK (conditional - skip with SKIP_GCLOUD=1)
        if [[ -z "$SKIP_GCLOUD" ]]; then
            if ! command -v gcloud &> /dev/null; then
                echo "  Installing Google Cloud SDK..."
                brew install google-cloud-sdk
            fi
            command -v kubectl &> /dev/null || brew install kubernetes-cli
            # GKE auth plugin for kubectl
            if ! gcloud components list 2>/dev/null | grep -q "gke-gcloud-auth-plugin.*Installed"; then
                brew install gke-gcloud-auth-plugin 2>/dev/null || true
            fi
            echo "  ✓ gcloud, kubectl, gke-gcloud-auth-plugin"
        else
            echo "  ⊘ Skipping gcloud (SKIP_GCLOUD=1)"
        fi

    elif [[ "$OS" == "windows" ]]; then
        mkdir -p "$DOTFILES_DIR/scripts"

        # Git Bash/MSYS2 needs Linux binary, regular Windows needs Windows binary
        local needs_install=false
        local needs_replace=false
        
        if ! command -v fzf &> /dev/null; then
            needs_install=true
        elif [[ -n "$MSYSTEM" ]] || [[ "$OSTYPE" == "msys" ]] || [[ -n "$MINGW_PREFIX" ]]; then
            # Check if existing fzf is Windows binary (won't work in Git Bash)
            if [[ -f "$DOTFILES_DIR/scripts/fzf.exe" ]] || ! "$DOTFILES_DIR/scripts/fzf" --version &>/dev/null; then
                needs_replace=true
            fi
        fi
        
        if [[ "$needs_install" == true ]] || [[ "$needs_replace" == true ]]; then
            echo "  Installing fzf..."
            # Remove old binary if exists
            rm -f "$DOTFILES_DIR/scripts/fzf" "$DOTFILES_DIR/scripts/fzf.exe"
            
            if [[ -n "$MSYSTEM" ]] || [[ "$OSTYPE" == "msys" ]] || [[ -n "$MINGW_PREFIX" ]]; then
                # Git Bash/MSYS2 - use Linux binary
                curl -fsSL "https://github.com/junegunn/fzf/releases/download/v0.59.0/fzf-0.59.0-linux_amd64.tar.gz" -o /tmp/fzf.tar.gz
                tar -xzf /tmp/fzf.tar.gz -C "$DOTFILES_DIR/scripts/" fzf && rm /tmp/fzf.tar.gz
                chmod +x "$DOTFILES_DIR/scripts/fzf"
            else
                # Regular Windows - use Windows binary
                curl -fsSL "https://github.com/junegunn/fzf/releases/download/v0.59.0/fzf-0.59.0-windows_amd64.zip" -o /tmp/fzf.zip
                unzip -o /tmp/fzf.zip -d "$DOTFILES_DIR/scripts/" && rm /tmp/fzf.zip
            fi
        fi
        echo "  ✓ fzf"

        if ! command -v direnv &> /dev/null; then
            echo "  Installing direnv..."
            curl -fsSL "https://github.com/direnv/direnv/releases/download/v2.35.0/direnv.windows-amd64.exe" -o "$DOTFILES_DIR/scripts/direnv.exe"
        fi
        echo "  ✓ direnv"

        command -v node &> /dev/null && echo "  ✓ Node.js $(node --version)" || echo "  ✗ Node.js (install: choco install nodejs-lts)"
        command -v go &> /dev/null && echo "  ✓ $(go version)" || echo "  ✗ Go (install: choco install golang)"
    fi
}

setup_scripts() {
    echo ""
    echo "[3/5] Setting up scripts..."
    chmod +x "$DOTFILES_DIR/scripts/"* 2>/dev/null || true
    echo "  ✓ Scripts made executable"
}

setup_macos_zsh() {
    echo ""
    echo "[4/5] Setting up Oh My Zsh (macOS)..."

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    # Restore our .zshrc symlink (Oh My Zsh overwrites it)
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    echo "  ✓ Oh My Zsh"

    local ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] || git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] || git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    [[ -d "$ZSH_CUSTOM/plugins/zsh-completions" ]] || git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    echo "  ✓ Zsh plugins"

    # Fix Homebrew zsh directory permissions (compaudit warning)
    if [[ -d "/opt/homebrew/share/zsh" ]]; then
        chmod go-w /opt/homebrew/share/zsh /opt/homebrew/share/zsh/site-functions 2>/dev/null || true
        echo "  ✓ Fixed Homebrew zsh permissions"
    fi
}

setup_windows_wsl() {
    echo ""
    echo "[4/5] Setting up WSL with native dev tools..."

    if ! command -v wsl.exe &> /dev/null && ! command -v wsl &> /dev/null; then
        echo "  ✗ WSL not available. Run in PowerShell (admin): wsl --install"
        return 1
    fi

    local wsl_list
    wsl_list=$(wsl -l -q 2>/dev/null | tr -d '\0' | tr -d ' ')
    if ! echo "$wsl_list" | grep -qi "ubuntu"; then
        echo "  Installing Ubuntu on WSL..."
        wsl --install -d Ubuntu --no-launch
        echo ""
        echo "  =================================================="
        echo "  Ubuntu installed! Initialize it first:"
        echo "  1. Run in PowerShell: wsl -d Ubuntu"
        echo "  2. Create username and password"
        echo "  3. Type exit and run ./setup.sh again"
        echo "  =================================================="
        return 0
    fi

    echo "  ✓ Ubuntu WSL found"
    echo ""
    echo "  Installing all native tools in WSL..."
    echo "  (This may take a few minutes on first run)"
    echo ""

    # Run WSL setup script (use MSYS_NO_PATHCONV to prevent path mangling)
    MSYS_NO_PATHCONV=1 wsl -d Ubuntu -- bash /mnt/c/Users/$USERNAME/dotfiles/scripts/wsl-setup.sh
}

setup_hyper_windows() {
    echo ""
    echo "[5/5] Setting up Hyper Terminal..."

    local hyper_config="$APPDATA/Hyper/.hyper.js"

    if [[ ! -d "$APPDATA/Hyper" ]]; then
        echo "  ✗ Hyper not installed. Download from: https://hyper.is"
        return 0
    fi

    if [[ -f "$hyper_config" ]]; then
        cp "$hyper_config" "$hyper_config.backup"
        # JavaScript needs double backslashes in source: C:\\Windows\\System32\\wsl.exe
        # In double-quoted bash string: \\\\ becomes \\ to sed, which outputs \ (single backslash)
        # To output \\ (double backslash) in file, we need \\\\ in sed, which requires \\\\\\\\ in bash string
        sed -i "s|shell: '.*'|shell: 'C:\\\\\\\\Windows\\\\\\\\System32\\\\\\\\wsl.exe'|" "$hyper_config"
        sed -i "s|shellArgs: \[.*\]|shellArgs: ['-d', 'Ubuntu']|" "$hyper_config"
        if ! grep -q "hyper-material-theme" "$hyper_config"; then
            sed -i "s|plugins: \[\]|plugins: ['hyper-material-theme', 'hyper-search', 'hyper-pane']|" "$hyper_config"
        fi
        echo "  ✓ Hyper configured for WSL + Zsh"
    fi
}

main() {
    create_symlinks
    install_host_tools
    setup_scripts

    if [[ "$OS" == "macos" ]]; then
        setup_macos_zsh
        echo ""
        echo "[5/5] Skipped (macOS)"
    elif [[ "$OS" == "windows" ]]; then
        setup_windows_wsl
        setup_hyper_windows
    fi

    echo ""
    echo "=================================================="
    echo "  Setup Complete!"
    echo "=================================================="
    echo ""
    echo "Next steps:"
    if [[ "$OS" == "macos" ]]; then
        echo "  1. Restart terminal or: source ~/.zshrc"
        echo "  2. Test: fp, gs, claude --version"
    elif [[ "$OS" == "windows" ]]; then
        echo "  1. Restart Hyper terminal"
        echo "  2. You will be in WSL Ubuntu with Zsh"
        echo "  3. All tools are native: node, npm, go, tsc, claude, docker"
        echo "  4. Use fp to fuzzy-find projects"
        echo "  5. Use proj or work to jump to directories"
    fi
    echo ""

    [[ -d "$BACKUP_DIR" ]] && echo "Old configs backed up to: $BACKUP_DIR"
}

main "$@"
