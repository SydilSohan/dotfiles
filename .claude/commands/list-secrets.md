# List Secrets

Show all secrets managed by this dotfiles repo and their mappings.

## Instructions

1. List all secrets in the vault:

```bash
find ~/dotfiles/secrets -type f ! -name ".gitkeep" ! -name "*.example"
```

2. For each secret, show:
   - The encrypted file path
   - Whether it's currently encrypted or decrypted (check if first line is "VAULT_ENCRYPTED")
   - The target project path (from secrets-restore script)

3. Display in a clear table format:

| Project | Secret | Status | Maps To |
|---------|--------|--------|---------|
| pie-go | service-account.json | Encrypted | ~/projects/pie-go/service-account.json |
| pie-frontend | .env | Encrypted | ~/projects/pie-frontend/.env |

4. Also check if the symlinks exist in the target projects and if they're valid.
