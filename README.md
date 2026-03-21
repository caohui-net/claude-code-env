# Claude Code Environment Template

Personal Claude Code environment configuration for quick setup on new machines.

## Contents

| Path | Description |
|------|-------------|
| `settings.json` | `~/.claude/settings.json` template (no secrets) |
| `hooks/hooks.json` | Recommended hooks configuration |
| `rules/common/` | Global coding rules (from [everything-claude-code](https://github.com/everything-claude-code)) |
| `mcp/mcp-servers.json` | MCP server reference configurations |
| `CLAUDE.md` | Global `~/CLAUDE.md` template |
| `install.sh` | One-click setup script |

## Quick Start

```bash
git clone <this-repo> ~/projects/claude-code-env
cd ~/projects/claude-code-env
bash install.sh
```

Then edit `~/.claude/settings.json` and set your `ANTHROPIC_AUTH_TOKEN`.

## Manual Steps

### 1. Settings
```bash
cp settings.json ~/.claude/settings.json
# Edit and set your token:
# "ANTHROPIC_AUTH_TOKEN": "sk-ant-..."
```

### 2. Rules
```bash
mkdir -p ~/.claude/rules/common
cp rules/common/*.md ~/.claude/rules/common/
```

### 3. Hooks
Review `hooks/hooks.json` and merge desired hooks into `~/.claude/settings.json`.

### 4. MCP Servers
Review `mcp/mcp-servers.json` for available MCP server configurations.
Add desired servers to `~/.claude/settings.json` under `mcpServers`.

### 5. Global CLAUDE.md (optional)
```bash
cp CLAUDE.md ~/CLAUDE.md
```

## Customization

- **settings.json**: Add your `ANTHROPIC_BASE_URL` if using a custom endpoint
- **CLAUDE.md**: Adjust language, workflow, and tool preferences
- **rules/**: Add or modify rules per project by placing `.md` files in `~/.claude/rules/`

## Sources

Rules and hooks adapted from [everything-claude-code](https://github.com/stevenaldinger/everything-claude-code).
