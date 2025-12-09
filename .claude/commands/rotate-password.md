# Rotate Vault Password

Change the vault password and re-encrypt all secrets.

## Instructions

1. First, decrypt ALL secrets:

```bash
# Find all encrypted files
for f in $(find ~/dotfiles/secrets -type f); do
    if head -1 "$f" | grep -q "^VAULT_ENCRYPTED"; then
        vault decrypt "$f"
    fi
done
```

2. Ask the user for the new password

3. Update the password file:

```bash
echo "<new-password>" > ~/.vault_password
chmod 600 ~/.vault_password
```

4. Re-encrypt ALL secrets:

```bash
for f in $(find ~/dotfiles/secrets -type f ! -name ".gitkeep" ! -name "*.example"); do
    vault encrypt "$f"
done
```

5. Commit and push:

```bash
cd ~/dotfiles
git add .
git commit -m "Rotate vault password - re-encrypted all secrets"
git push
```

6. Remind the user:
   - Update `~/.vault_password` on ALL other machines
   - Pull the latest dotfiles on other machines
   - The secrets will automatically work with the new password
