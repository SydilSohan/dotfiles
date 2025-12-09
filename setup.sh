#!/bin/bash
# =============================================================================
# Dotfiles Bootstrap Script (Cross-Platform: macOS + Windows/Git Bash)
# =============================================================================
# Run this on a new machine to set up your dev environment
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

# -----------------------------------------------------------------------------
# Backup existing files
# -----------------------------------------------------------------------------
backup_if_exists() {
    if [ -f "$1" ] || [ -L "$1" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "  Backing up $1"
        mv "$1" "$BACKUP_DIR/"
    fi
}

# -----------------------------------------------------------------------------
# Create symlinks
# -----------------------------------------------------------------------------
create_symlinks() {
    echo ""
    echo "[1/4] Creating symlinks..."

    backup_if_exists "$HOME/.gitconfig"
    ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

    if [[ "$OS" == "macos" ]]; then
        # macOS uses zsh by default
        backup_if_exists "$HOME/.zshrc"
        ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
        echo "  ✓ Linked .zshrc and .gitconfig"
    else
        # Windows Git Bash / Linux uses bash
        backup_if_exists "$HOME/.bashrc"
        ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
        echo "  ✓ Linked .bashrc and .gitconfig"
    fi
}

# -----------------------------------------------------------------------------
# Install tools
# -----------------------------------------------------------------------------
install_tools() {
    echo ""
    echo "[2/4] Installing tools..."

    if [[ "$OS" == "macos" ]]; then
        # macOS - use Homebrew
        if command -v brew &> /dev/null; then
            echo "  Homebrew found."

            if ! command -v fzf &> /dev/null; then
                echo "  Installing fzf..."
                brew install fzf
            else
                echo "  ✓ fzf already installed"
            fi

            if ! command -v tmux &> /dev/null; then
                echo "  Installing tmux..."
                brew install tmux
            else
                echo "  ✓ tmux already installed"
            fi
        else
            echo "  Homebrew not found. Install it first:"
            echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        fi

    elif [[ "$OS" == "windows" ]]; then
        # Windows - use Chocolatey
        if command -v choco &> /dev/null; then
            echo "  Chocolatey found."

            if ! command -v fzf &> /dev/null; then
                echo "  Installing fzf..."
                choco install fzf -y 2>/dev/null || echo "  (Run as admin to install fzf)"
            else
                echo "  ✓ fzf already installed"
            fi
        else
            echo "  Chocolatey not found. Install in admin PowerShell:"
            echo "  Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        fi
    fi
}

# -----------------------------------------------------------------------------
# Check dev tools
# -----------------------------------------------------------------------------
check_dev_tools() {
    echo ""
    echo "[3/4] Checking dev tools..."

    # Node
    if command -v node &> /dev/null; then
        echo "  ✓ Node.js $(node --version)"
    else
        echo "  ✗ Node.js not found"
        if [[ "$OS" == "macos" ]]; then
            echo "    Install: brew install node"
        else
            echo "    Install: choco install nodejs-lts"
        fi
    fi

    # TypeScript
    if command -v tsc &> /dev/null; then
        echo "  ✓ TypeScript $(tsc --version)"
    else
        echo "  ✗ TypeScript not found"
        echo "    Install: npm install -g typescript"
    fi

    # Go
    if command -v go &> /dev/null; then
        echo "  ✓ $(go version)"
    else
        echo "  ✗ Go not found"
        if [[ "$OS" == "macos" ]]; then
            echo "    Install: brew install go"
        else
            echo "    Install: choco install golang"
        fi
    fi

    # Git
    if command -v git &> /dev/null; then
        echo "  ✓ Git $(git --version | cut -d' ' -f3)"
    else
        echo "  ✗ Git not found"
    fi

    # Docker
    if command -v docker &> /dev/null; then
        echo "  ✓ Docker found"
    else
        echo "  ✗ Docker not found (optional)"
    fi

    # tmux (macOS only typically)
    if [[ "$OS" == "macos" ]]; then
        if command -v tmux &> /dev/null; then
            echo "  ✓ tmux $(tmux -V)"
        else
            echo "  ✗ tmux not found"
            echo "    Install: brew install tmux"
        fi
    fi
}

# -----------------------------------------------------------------------------
# Setup scripts
# -----------------------------------------------------------------------------
setup_scripts() {
    echo ""
    echo "[4/4] Setting up scripts..."

    chmod +x "$DOTFILES_DIR/scripts/"* 2>/dev/null || true
    echo "  ✓ Scripts made executable"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    create_symlinks
    install_tools
    check_dev_tools
    setup_scripts

    echo ""
    echo "=================================================="
    echo "  Setup Complete!"
    echo "=================================================="
    echo ""
    echo "Next steps:"
    if [[ "$OS" == "macos" ]]; then
        echo "  1. Restart terminal or run: source ~/.zshrc"
    else
        echo "  1. Restart terminal or run: source ~/.bashrc"
    fi
    echo "  2. Test with: gs (git status alias)"
    echo "  3. Use 'fp' to fuzzy-find and switch projects"
    echo "  4. Use 'cht <topic>' for quick reference"
    echo ""

    if [ -d "$BACKUP_DIR" ]; then
        echo "Old configs backed up to: $BACKUP_DIR"
        echo ""
    fi
}

main "$@"
