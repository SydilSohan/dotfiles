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
        if ! command -v brew &> /dev/null; then
            echo "  Homebrew not found. Installing..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Add Homebrew to PATH for this session (Apple Silicon)
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        fi

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

        if ! command -v direnv &> /dev/null; then
            echo "  Installing direnv..."
            brew install direnv
        else
            echo "  ✓ direnv already installed"
        fi

    elif [[ "$OS" == "windows" ]]; then
        # Windows - download fzf directly (no admin needed)
        if ! command -v fzf &> /dev/null; then
            echo "  Installing fzf..."
            local FZF_VERSION="0.59.0"
            local FZF_URL="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-windows_amd64.zip"

            if curl -fsSL "$FZF_URL" -o /tmp/fzf.zip; then
                unzip -o /tmp/fzf.zip -d "$DOTFILES_DIR/scripts/" && rm /tmp/fzf.zip
                echo "  ✓ fzf installed to dotfiles/scripts/"
            else
                echo "  ✗ Failed to download fzf"
                echo "    Manual install: choco install fzf (as admin)"
            fi
        else
            echo "  ✓ fzf already installed"
        fi

        # Windows - download direnv directly
        if ! command -v direnv &> /dev/null; then
            echo "  Installing direnv..."
            local DIRENV_VERSION="2.35.0"
            local DIRENV_URL="https://github.com/direnv/direnv/releases/download/v${DIRENV_VERSION}/direnv.windows-amd64.exe"

            if curl -fsSL "$DIRENV_URL" -o "$DOTFILES_DIR/scripts/direnv.exe"; then
                echo "  ✓ direnv installed to dotfiles/scripts/"
            else
                echo "  ✗ Failed to download direnv"
            fi
        else
            echo "  ✓ direnv already installed"
        fi
    fi
}

# -----------------------------------------------------------------------------
# Install dev tools
# -----------------------------------------------------------------------------
install_dev_tools() {
    echo ""
    echo "[3/4] Installing dev tools..."

    if [[ "$OS" == "macos" ]]; then
        # Node.js
        if ! command -v node &> /dev/null; then
            echo "  Installing Node.js..."
            brew install node
        else
            echo "  ✓ Node.js $(node --version)"
        fi

        # Go
        if ! command -v go &> /dev/null; then
            echo "  Installing Go..."
            brew install go
        else
            echo "  ✓ $(go version)"
        fi

    elif [[ "$OS" == "windows" ]]; then
        # On Windows, check and give instructions (needs admin for choco)
        if command -v node &> /dev/null; then
            echo "  ✓ Node.js $(node --version)"
        else
            echo "  ✗ Node.js not found"
            echo "    Install (admin PowerShell): choco install nodejs-lts -y"
        fi

        if command -v go &> /dev/null; then
            echo "  ✓ $(go version)"
        else
            echo "  ✗ Go not found"
            echo "    Install (admin PowerShell): choco install golang -y"
        fi
    fi

    # TypeScript (cross-platform via npm)
    if command -v node &> /dev/null; then
        if ! command -v tsc &> /dev/null; then
            echo "  Installing TypeScript..."
            npm install -g typescript
        else
            echo "  ✓ TypeScript $(tsc --version)"
        fi
    fi

    # Claude Code (cross-platform via npm)
    if command -v node &> /dev/null; then
        if ! command -v claude &> /dev/null; then
            echo "  Installing Claude Code..."
            npm install -g @anthropic-ai/claude-code
        else
            echo "  ✓ Claude Code installed"
        fi
    fi

    # Git check
    if command -v git &> /dev/null; then
        echo "  ✓ Git $(git --version | cut -d' ' -f3)"
    else
        echo "  ✗ Git not found - please install manually"
    fi

    # Docker check (optional)
    if command -v docker &> /dev/null; then
        echo "  ✓ Docker found"
    else
        echo "  ✗ Docker not found (optional)"
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
    install_dev_tools
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
