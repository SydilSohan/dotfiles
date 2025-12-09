# Add Project Secret

Add a new secret file from a project to the dotfiles vault.

## Arguments
- $ARGUMENTS: The project name and secret file path (e.g., "pie-api .env" or "my-project service-account.json")

## Instructions

1. Parse the arguments to get project name and secret filename
2. Create the secrets directory: `mkdir -p ~/dotfiles/secrets/<project-name>`
3. Copy the secret file from the project to dotfiles:
   - From: `~/projects/<project-name>/<filename>`
   - To: `~/dotfiles/secrets/<project-name>/<filename>`
4. Encrypt the secret: `vault encrypt ~/dotfiles/secrets/<project-name>/<filename>`
5. Add the mapping to `scripts/secrets-restore` by adding a new block:

```bash
# -----------------------------------------------------------------------------
# <project-name>
# -----------------------------------------------------------------------------
if [[ -d "$HOME/projects/<project-name>" ]]; then
    echo "[<project-name>]"
    if [[ -f "$SECRETS_DIR/<project-name>/<filename>" ]]; then
        ensure_decrypted "$SECRETS_DIR/<project-name>/<filename>"
        create_link "$SECRETS_DIR/<project-name>/<filename>" "$HOME/projects/<project-name>/<filename>"
    fi
    echo ""
fi
```

6. Commit the changes:
```bash
cd ~/dotfiles
git add .
git commit -m "Add <project-name> secret: <filename>"
git push
```

7. Inform the user that the secret has been added and will be available on other machines after they pull and run `secrets-restore`.
