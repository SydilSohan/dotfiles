# Dotfiles

My dev environment configuration for Windows (Git Bash).

## Quick Start

```bash
# Clone to home directory
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles

# Run setup
cd ~/dotfiles
./setup.sh

# Reload shell
source ~/.bashrc
```

## What's Included

| File | Purpose |
|------|---------|
| `.bashrc` | Shell aliases, functions, prompt |
| `.gitconfig` | Git aliases and settings |
| `scripts/` | Utility scripts (tmux-sessionizer) |
| `secrets/` | Encrypted API keys (ansible-vault) |

## Key Features

### Aliases

```bash
# Git shortcuts
gs          # git status
gaa         # git add --all
gcm "msg"   # git commit -m "msg"
gp          # git push
gl          # git log --oneline

# Navigation
proj        # cd ~/projects
..          # cd ..

# Development
nr dev      # npm run dev
nrb         # npm run build
```

### Functions

```bash
# Project switcher (requires fzf)
fp          # fuzzy find project and cd
fpc         # fuzzy find and open in Cursor

# Quick commit
gacp "msg"  # git add all, commit, push

# Utilities
mkcd dir    # mkdir + cd
killport 3000  # kill process on port
cht go/arrays  # cheat sheet lookup
```

## Secrets Management

```bash
# Encrypt your API keys
ansible-vault encrypt secrets/api_keys.env

# View encrypted file
ansible-vault view secrets/api_keys.env

# Decrypt when needed
ansible-vault decrypt secrets/api_keys.env
```

## Required Tools

Install via Chocolatey:
```powershell
choco install git nodejs-lts golang fzf
npm install -g typescript
```
