# Dotfiles Repository

This is a cross-platform (Windows + macOS) dotfiles repository for dev environment setup.

## Structure

```
~/dotfiles/
├── .bashrc                 # Shell config for Windows/Linux
├── .zshrc                  # Shell config for macOS
├── .gitconfig              # Git aliases and settings
├── scripts/
│   ├── vault               # Encrypt/decrypt secrets (AES-256)
│   ├── secrets-restore     # Symlink secrets to project directories
│   ├── gh-auth             # GitHub CLI authentication with encrypted token
│   └── tmux-sessionizer    # Project switching with tmux
├── secrets/                # Encrypted project secrets
│   ├── github/
│   │   └── token           # GitHub personal access token
│   ├── pie-go/
│   │   └── service-account.json
│   └── pie-frontend/
│       └── .env
└── setup.sh                # Bootstrap script (auto-detects OS)
```

## Secrets Management

Secrets are encrypted with AES-256 using OpenSSL and are safe to commit to GitHub.

### Key Files
- `~/.vault_password` - Contains the encryption password (NEVER committed)
- `scripts/vault` - Encrypt/decrypt tool
- `scripts/secrets-restore` - Maps secrets to project directories via symlinks
- `scripts/gh-auth` - GitHub CLI authentication using encrypted token

### Vault Commands
```bash
vault encrypt <file>    # Encrypt a file in place
vault decrypt <file>    # Decrypt a file in place
vault view <file>       # View contents without decrypting
vault edit <file>       # Decrypt, edit, re-encrypt
vault set-password      # Set/change vault password
```

### GitHub CLI Authentication

GitHub CLI (`gh`) is installed automatically by `setup.sh`. Authentication uses an encrypted personal access token.

```bash
gh-auth setup       # Interactive setup - create and encrypt a new token
gh-auth             # Authenticate gh CLI using stored encrypted token
gh-auth status      # Check authentication status
gh-auth logout      # Log out from GitHub CLI
```

#### Setting Up GitHub Token

1. Run `gh-auth setup`
2. Go to https://github.com/settings/tokens?type=beta
3. Create a fine-grained token with these permissions:
   - Contents: Read and write
   - Metadata: Read-only
   - Pull requests: Read and write
4. Paste the token when prompted
5. Token is automatically encrypted with vault

#### Token Storage
- Token stored at: `~/dotfiles/secrets/github/token`
- Encrypted with the same vault password as other secrets
- Safe to commit to git (encrypted)

### Adding New Project Secrets

1. Create directory: `mkdir -p ~/dotfiles/secrets/<project-name>`
2. Copy secret: `cp ~/projects/<project>/.env ~/dotfiles/secrets/<project-name>/`
3. Encrypt: `vault encrypt ~/dotfiles/secrets/<project-name>/.env`
4. Edit `scripts/secrets-restore` to add the symlink mapping
5. Commit and push

### Secrets Mapping

The `secrets-restore` script contains hardcoded mappings from dotfiles to project directories:

```bash
# Example mapping in secrets-restore:
~/dotfiles/secrets/pie-go/service-account.json → ~/projects/pie-go/service-account.json
~/dotfiles/secrets/pie-frontend/.env → ~/projects/pie-frontend/.env
```

## New Machine Setup

1. Clone: `git clone https://github.com/SydilSohan/dotfiles.git ~/dotfiles`
2. Run setup: `cd ~/dotfiles && ./setup.sh`
3. Set password: `echo "your-password" > ~/.vault_password && chmod 600 ~/.vault_password`
4. Clone projects to `~/projects/`
5. Restore secrets: `secrets-restore`
6. Authenticate GitHub: `gh-auth`

## Cross-Platform

- Windows: Uses `.bashrc` (Git Bash), Chocolatey for packages
- macOS: Uses `.zshrc`, Homebrew for packages
- `setup.sh` auto-detects OS and links appropriate config
