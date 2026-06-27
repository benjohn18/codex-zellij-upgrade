#!/usr/bin/env bash
set -euo pipefail

# Install left-side vertical tabs for Zellij for the current Unix user.
# It is safe to run repeatedly. Existing files are backed up before edits.

ts="$(date +%Y%m%d-%H%M%S)"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
zellij_config_dir="${HOME}/.config/zellij"
zellij_layout_dir="${zellij_config_dir}/layouts"
zellij_plugin_dir="${zellij_config_dir}/plugins"
zellij_cache_dir="${HOME}/.cache/zellij"
zellij_config="${zellij_config_dir}/config.kdl"
layout_file="${zellij_layout_dir}/vertical-tabs-left.kdl"
plugin_file="${zellij_plugin_dir}/zellij-vertical-tabs.wasm"
permissions_file="${zellij_cache_dir}/permissions.kdl"
bashrc="${HOME}/.bashrc"
ztasks="${HOME}/bin/ztasks"
bundled_plugin="${script_dir}/zellij-vertical-tabs.wasm"
old_codex_status_scripts=(
    codex-tab-monitor
    ztab-status
    codex-status
    codex-status-watch
    codexz
)

backup_file() {
    local file="$1"
    if [ -e "$file" ]; then
        cp "$file" "${file}.bak-zellij-vertical-${ts}"
        echo "[backup] ${file}.bak-zellij-vertical-${ts}"
    fi
}

need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[error] missing command: $1" >&2
        exit 1
    fi
}

need_cmd zellij
need_cmd python3

mkdir -p "$zellij_layout_dir" "$zellij_plugin_dir" "$zellij_cache_dir" "${HOME}/bin"

echo "[info] zellij version: $(zellij --version)"

backup_file "$bashrc"
backup_file "$zellij_config"
backup_file "$layout_file"
backup_file "$permissions_file"
backup_file "$ztasks"

if [ ! -s "$zellij_config" ]; then
    echo "[write] creating default zellij config: $zellij_config"
    zellij setup --dump-config > "$zellij_config"
fi

if [ ! -s "$bundled_plugin" ]; then
    echo "[error] bundled plugin not found: $bundled_plugin" >&2
    echo "[error] put zellij-vertical-tabs.wasm next to zellij_init.sh" >&2
    exit 1
fi

echo "[write] copying vertical tab plugin from: $bundled_plugin"
cp "$bundled_plugin" "$plugin_file"

echo "[write] layout: $layout_file"
cat > "$layout_file" <<EOF
layout {
    pane split_direction="Vertical" {
        pane size=24 borderless=true {
            plugin location="file:${plugin_file}" {
                format "#[fg=muted,bold]{index}  #[fg=white]{name}"
                format_active "#[fg=black,bg=39,fill,bold] {index}  {name} "
                indicator_active ""
                indicator_fullscreen "F"
                indicator_sync "S"
                max_name_length 20
                border "#[fg=238]|"
            }
        }

        pane focus=true
    }

    pane size=1 borderless=true {
        plugin location="zellij:status-bar"
    }
}
EOF

echo "[write] plugin permission: $permissions_file"
python3 - "$permissions_file" "$plugin_file" <<'PY'
import pathlib
import sys

permissions = pathlib.Path(sys.argv[1])
plugin = sys.argv[2]
block = f'''"{plugin}" {{
    ReadApplicationState
    ChangeApplicationState
}}
'''

text = permissions.read_text() if permissions.exists() else ""
if plugin not in text:
    if text and not text.endswith("\n"):
        text += "\n"
    text += block
    permissions.write_text(text)
PY

echo "[write] zellij keybindings in: $zellij_config"
python3 - "$zellij_config" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text()

if "keybinds" not in text:
    text = 'keybinds {\n}\n\n' + text

lines = text.splitlines()
target_keys = {"Alt w", "Alt s", "Alt i", "Alt o", "Alt r"}
filtered = []
for line in lines:
    match = re.match(r'\s*bind\s+"([^"]+)"\s+\{.*\}\s*$', line)
    if match and match.group(1) in target_keys:
        continue
    filtered.append(line)

insert_block = [
    '    // Installed by zellij_init.sh: vertical-tab friendly shortcuts.',
    '    shared_except "locked" {',
    '        bind "Alt w" { GoToPreviousTab; }',
    '        bind "Alt s" { GoToNextTab; }',
    '        bind "Alt i" { MoveTab "left"; }',
    '        bind "Alt o" { MoveTab "right"; }',
    '        bind "Alt r" { SwitchToMode "renametab"; TabNameInput 0; }',
    '    }',
]

out = []
inserted = False
for line in filtered:
    out.append(line)
    if not inserted and re.match(r'\s*keybinds\b.*\{\s*$', line):
        out.extend(insert_block)
        inserted = True

if not inserted:
    out = ['keybinds {', *insert_block, '}', *filtered]

path.write_text("\n".join(out) + "\n")
PY

echo "[write] shell helpers in: $bashrc"
python3 - "$bashrc" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text() if path.exists() else ""
begin = "# >>> zellij vertical tabs init >>>"
end = "# <<< zellij vertical tabs init <<<"

block = r'''# >>> zellij vertical tabs init >>>
# ze ls             list sessions
# ze <name>         attach existing session, or create with left-side vertical tabs
# ze kill <name>    kill and delete a session
ze() {
    local cmd="${1:-}"
    local target="${2:-}"

    if [ "$cmd" = "ls" ]; then
        env -u ZELLIJ -u ZELLIJ_SESSION_NAME zellij list-sessions
    elif [ "$cmd" = "kill" ]; then
        if [ -n "$target" ]; then
            env -u ZELLIJ -u ZELLIJ_SESSION_NAME zellij kill-session "$target" 2>/dev/null
            env -u ZELLIJ -u ZELLIJ_SESSION_NAME zellij delete-session "$target" 2>/dev/null
            echo "deleted zellij session: $target"
        else
            echo "usage: ze kill <session>"
        fi
    elif [ -n "$cmd" ]; then
        if env -u ZELLIJ -u ZELLIJ_SESSION_NAME zellij list-sessions --short --no-formatting 2>/dev/null | grep -qx "$cmd"; then
            env -u ZELLIJ -u ZELLIJ_SESSION_NAME zellij attach "$cmd"
        else
            env -u ZELLIJ -u ZELLIJ_SESSION_NAME zellij --session "$cmd" --new-session-with-layout vertical-tabs-left
        fi
    else
        echo "usage: ze ls | ze <session> | ze kill <session>"
    fi
}

zev() {
    ze "$@"
}
# <<< zellij vertical tabs init <<<
'''

pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end) + r"\n?", re.S)
text = pattern.sub("", text).rstrip() + "\n\n" + block + "\n"
path.write_text(text)
PY

echo "[cleanup] old Codex tab-status monitor"
if pgrep -u "$(id -u)" -f 'codex-tab-monitor|codex-status-watch|ztab-status|codexz' >/dev/null 2>&1; then
    pkill -u "$(id -u)" -f 'codex-tab-monitor|codex-status-watch|ztab-status|codexz' 2>/dev/null || true
fi
for name in "${old_codex_status_scripts[@]}"; do
    rm -f "${HOME}/bin/${name}"
done

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

echo "[write] launcher: $ztasks"
cat > "$ztasks" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SESSION="${1:-task_group}"

if env -u ZELLIJ -u ZELLIJ_SESSION_NAME zellij list-sessions --short --no-formatting 2>/dev/null | grep -qx "$SESSION"; then
    exec env -u ZELLIJ -u ZELLIJ_SESSION_NAME zellij attach "$SESSION"
else
    exec env -u ZELLIJ -u ZELLIJ_SESSION_NAME zellij --session "$SESSION" --new-session-with-layout vertical-tabs-left
fi
EOF
chmod +x "$ztasks"

echo "[check] bash syntax"
bash -n "$bashrc"
bash -n "$ztasks"

echo "[check] zellij config"
zellij setup --check >/dev/null
zellij setup --dump-layout vertical-tabs-left >/dev/null

cat <<'EOF'

[done] Zellij vertical tabs installed.

Use in current shell:
  source ~/.bashrc
  ze t

Start Codex after source ~/.bashrc:
  codex

Use from SSH:
  ssh -tt USER@SERVER '~/bin/ztasks t'

Shortcuts:
  Alt+w    previous tab
  Alt+s    next tab
  Alt+i    move current tab up/forward
  Alt+o    move current tab down/backward
  Alt+r    rename current tab

Important:
  Existing sessions keep their old layout. Recreate a session to apply vertical tabs:
    ze kill t
    ze t
EOF
