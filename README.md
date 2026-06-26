# codex-zellij-upgrade

English | [中文](#中文)

![codex-zellij-upgrade screenshot](assets/codex-zellij-upgrade.png)

## English

Simple Zellij upgrades for Codex-heavy SSH workflows:

- left-side vertical tabs
- stable named sessions through `ze`
- simple tab shortcuts
- Codex tab status markers: `[ing]`, `[done]`, `[!!!]`

### Install

```bash
bash zellij_init.sh
source ~/.bashrc
ze t
```

Restart Codex after installing:

```bash
codex
```

### Main Commands

```bash
ze name       # enter or create session "name"
ze ls         # list sessions
ze kill name  # kill/delete session "name"
```

### Shortcuts

- `Alt+w`: previous tab
- `Alt+s`: next tab
- `Alt+r`: rename current tab
- `Alt+i`: move current tab up
- `Alt+o`: move current tab down
- `Ctrl+q`: detach session
- `Ctrl+t`, then `n`: new tab

### Codex Status

- `[ing]`: Codex is working
- `[done]`: Codex finished the current turn
- `[!!!]`: Codex is waiting for approval

If status gets stuck:

```bash
ztab-status ing
ztab-status done
ztab-status !!!
```

### Files

- `zellij_init.sh`: full installer
- `zellij-vertical-tabs.wasm`: bundled vertical tab plugin
- `user_readme.md`: short user cheat sheet

### License

MIT. The bundled `zellij-vertical-tabs.wasm` comes from the MIT-licensed `cfal/zellij-vertical-tabs` project. See `THIRD_PARTY_NOTICES.md`.

---

## 中文

这是给 Codex + SSH + Zellij 工作流用的小升级：

- 左侧常驻竖向 tab
- 用 `ze` 管理固定名字的 session
- 简单 tab 快捷键
- Codex tab 状态：`[ing]`、`[done]`、`[!!!]`

### 安装

```bash
bash zellij_init.sh
source ~/.bashrc
ze t
```

安装后需要重新启动 Codex：

```bash
codex
```

### 主要命令

```bash
ze name       # 进入或创建 name 这个 session
ze ls         # 查看所有 session
ze kill name  # 删除 name 这个 session
```

### 快捷键

- `Alt+w`: 上一个 tab
- `Alt+s`: 下一个 tab
- `Alt+r`: 改当前 tab 名字
- `Alt+i`: 当前 tab 往上移动
- `Alt+o`: 当前 tab 往下移动
- `Ctrl+q`: 挂起 / detach 当前 session
- `Ctrl+t` 后按 `n`: 新建 tab

### Codex 状态

- `[ing]`: Codex 正在工作
- `[done]`: Codex 已完成当前回复
- `[!!!]`: Codex 正在等待授权

如果状态卡住，可以手动修正当前 tab：

```bash
ztab-status ing
ztab-status done
ztab-status !!!
```

### 文件

- `zellij_init.sh`: 完整安装脚本
- `zellij-vertical-tabs.wasm`: 内置竖向 tab 插件
- `user_readme.md`: 给普通用户看的简短说明

### 开源协议

MIT。内置的 `zellij-vertical-tabs.wasm` 来自 MIT 协议的 `cfal/zellij-vertical-tabs` 项目，见 `THIRD_PARTY_NOTICES.md`。
