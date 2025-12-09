# Sync Secrets

Pull latest dotfiles and restore secrets to projects.

## Instructions

Use this after someone updates secrets on another machine.

1. Pull latest changes:

```bash
cd ~/dotfiles
git pull
```

2. Run secrets restore:

```bash
secrets-restore
```

This will:
- Decrypt any encrypted secrets (using ~/.vault_password)
- Create/update symlinks from dotfiles to project directories

3. Verify the secrets are in place:

```bash
# Check symlinks
ls -la ~/projects/pie-go/service-account.json
ls -la ~/projects/pie-frontend/.env
```

4. If there are issues:
   - Check ~/.vault_password exists and has the correct password
   - Check the project directories exist in ~/projects/
   - Run `vault view <file>` to verify decryption works
