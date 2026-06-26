# Support

## Tested Environment

- Linux server over SSH
- Zellij `0.44.1`
- Bash
- Codex CLI running inside Zellij

Other environments may work, but they are not the main target yet.

## Restore / Rollback

`zellij_init.sh` backs up edited files before writing them. Backup files look like:

```text
~/.bashrc.bak-zellij-vertical-YYYYMMDD-HHMMSS
~/.config/zellij/config.kdl.bak-zellij-vertical-YYYYMMDD-HHMMSS
~/.config/zellij/layouts/vertical-tabs-left.kdl.bak-zellij-vertical-YYYYMMDD-HHMMSS
~/.cache/zellij/permissions.kdl.bak-zellij-vertical-YYYYMMDD-HHMMSS
```

To restore manually:

```bash
cp ~/.bashrc.bak-zellij-vertical-YYYYMMDD-HHMMSS ~/.bashrc
source ~/.bashrc
```

If a Zellij session becomes broken, delete only that session:

```bash
ze kill name
```

Then recreate it:

```bash
ze name
```

## Useful Debug Info

When reporting a bug, include:

```bash
zellij --version
zellij setup --check
type ze
env | grep '^ZELLIJ'
zellij list-sessions --no-formatting
```
