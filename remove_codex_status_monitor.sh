#!/usr/bin/env bash
set -euo pipefail

# Remove the old Codex tab-status monitor installed by early versions of this project.
# This keeps vertical tabs, ze helpers, Zellij shortcuts, and the Zellij status bar.

ts="$(date +%Y%m%d-%H%M%S)"
bashrc="${HOME}/.bashrc"
old_scripts=(
    codex-tab-monitor
    ztab-status
    codex-status
    codex-status-watch
    codexz
)

backup_file() {
    local file="$1"
    if [ -e "$file" ]; then
        cp "$file" "${file}.bak-remove-codex-status-${ts}"
        echo "[backup] ${file}.bak-remove-codex-status-${ts}"
    fi
}

mkdir -p "${HOME}/bin"
backup_file "$bashrc"

echo "[stop] old monitor processes for current user"
pkill -u "$(id -u)" -f 'codex-tab-monitor|codex-status-watch|ztab-status|codexz' 2>/dev/null || true

echo "[remove] old status scripts"
for name in "${old_scripts[@]}"; do
    rm -f "${HOME}/bin/${name}"
done

echo "[edit] remove old codex status block from ~/.bashrc"
python3 - "$bashrc" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text() if path.exists() else ""
begin = "# >>> codex zellij tab status >>>"
end = "# <<< codex zellij tab status <<<"
pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end) + r"\n?", re.S)
text = pattern.sub("", text)
path.write_text(text.rstrip() + "\n")
PY

bash -n "$bashrc"

cat <<'EOF'

[done] Codex tab-status monitor removed.

Run in existing shells:
  source ~/.bashrc

What remains:
  - left-side Zellij vertical tabs
  - ze / ze ls / ze kill
  - Alt+w Alt+s Alt+r Alt+i Alt+o shortcuts
  - Zellij built-in status bar
EOF
