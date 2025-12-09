# Setup New Machine

Guide to set up this dotfiles repo on a new machine.

## Instructions

Walk the user through these steps:

### 1. Check Prerequisites

Verify these are installed:
- Git
- For Windows: Git Bash, Chocolatey
- For macOS: Homebrew

### 2. Clone Dotfiles

```bash
git clone https://github.com/SydilSohan/dotfiles.git ~/dotfiles
```

### 3. Run Setup Script

```bash
cd ~/dotfiles && ./setup.sh
```

This will:
- Detect the OS (Windows/macOS)
- Link `.bashrc` or `.zshrc` appropriately
- Link `.gitconfig`
- Check for required tools (node, go, typescript, fzf)

### 4. Set Vault Password

Ask the user for their vault password, then:

```bash
echo "<password>" > ~/.vault_password
chmod 600 ~/.vault_password
```

### 5. Reload Shell

```bash
source ~/.bashrc   # Windows/Linux
source ~/.zshrc    # macOS
```

### 6. Clone Projects

The user needs to clone their projects to `~/projects/`:

```bash
mkdir -p ~/projects
cd ~/projects
git clone <repo-url> pie-go
git clone <repo-url> pie-frontend
# ... other projects
```

### 7. Restore Secrets

```bash
secrets-restore
```

This decrypts and symlinks all secrets to their project directories.

### 8. Verify

```bash
# Check aliases work
gs   # should run git status

# Check secrets are linked
ls -la ~/projects/pie-go/service-account.json
ls -la ~/projects/pie-frontend/.env
```

### Done!

The machine is now set up with:
- Shell aliases and functions
- Git configuration
- Decrypted secrets linked to projects
