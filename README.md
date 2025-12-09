# Dotfiles

My dev environment configuration (Windows + macOS).

## Quick Start

```bash
# Clone to home directory
git clone https://github.com/SydilSohan/dotfiles.git ~/dotfiles

# Run setup (auto-detects OS)
cd ~/dotfiles && ./setup.sh

# Reload shell
source ~/.bashrc  # Windows/Linux
source ~/.zshrc   # macOS
```

## What's Included

| File | Purpose |
|------|---------|
| `.bashrc` | Shell config (Windows/Linux) |
| `.zshrc` | Shell config (macOS) |
| `.gitconfig` | Git aliases and settings |
| `scripts/vault` | Encrypt/decrypt secrets |
| `scripts/secrets-restore` | Symlink secrets to projects |
| `secrets/` | Encrypted project secrets |

## Secrets Management

Secrets are encrypted with AES-256 and safe to commit.

```bash
# First time: set your vault password
vault set-password

# Encrypt a secret
vault encrypt secrets/pie-go/service-account.json

# View encrypted file (without decrypting)
vault view secrets/pie-go/service-account.json

# Decrypt when needed
vault decrypt secrets/pie-go/service-account.json

# Edit encrypted file (decrypts, opens editor, re-encrypts)
vault edit secrets/pie-frontend/.env
```

### Restore Secrets to Projects

After cloning on a new machine:

```bash
# Decrypt and symlink all secrets to project directories
secrets-restore
```

This links:
- `secrets/pie-go/service-account.json` → `~/projects/pie-go/service-account.json`
- `secrets/pie-frontend/.env` → `~/projects/pie-frontend/.env`

## Key Aliases

```bash
# Git
gs          # git status
gaa         # git add --all
gcm "msg"   # git commit -m "msg"
gp          # git push
gl          # git log --oneline

# Navigation
proj        # cd ~/projects
fp          # fuzzy find project (requires fzf)

# Development
nr dev      # npm run dev
gacp "msg"  # git add, commit, push in one command
killport 3000  # kill process on port
cht go/arrays  # quick cheat sheet
```

## Required Tools

**Windows (Chocolatey):**
```powershell
choco install git nodejs-lts golang fzf
npm install -g typescript
```

**macOS (Homebrew):**
```bash
brew install node go fzf tmux
npm install -g typescript
```
