# Claude Code Environment Template

Personal Claude Code environment configuration for quick setup on new machines.

## Contents

| Path | Description |
|------|-------------|
| `settings.json` | `~/.claude/settings.json` template (no secrets) |
| `hooks/hooks.json` | Recommended hooks configuration |
| `rules/common/` | Global coding rules |
| `rules/typescript/` | TypeScript language-specific rules |
| `rules/python/` | Python language-specific rules |
| `rules/golang/` | Golang language-specific rules |
| `skills/` | Claude Code skills (planning, writing, research, etc.) |
| `profiles/` | Optional CLAUDE.md profiles for different scenarios |
| `mcp/mcp-servers.json` | MCP server reference configurations |
| `CLAUDE.md` | Global `~/CLAUDE.md` template |
| `install.sh` | One-click setup script |

## 项目状态文件

- `project-state.json`：人工维护的项目级事实源（包含阶段、组件、关键文件）
- `.omc/session-context.json`：当前/最近会话状态（会话级信息）
- `.project-context.json`：兼容旧流程的生成文件（自动生成，不要手动编辑）

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
# Common rules
mkdir -p ~/.claude/rules/common
cp rules/common/*.md ~/.claude/rules/common/

# Language-specific rules
cp -r rules/typescript ~/.claude/rules/
cp -r rules/python ~/.claude/rules/
cp -r rules/golang ~/.claude/rules/
```

### 3. Hooks
Review `hooks/hooks.json` and merge desired hooks into `~/.claude/settings.json`.

### 4. MCP Servers
Review `mcp/mcp-servers.json` for available MCP server configurations.
Add desired servers to `~/.claude/settings.json` under `mcpServers`.

### 5. Skills (optional)
```bash
cp -r skills ~/.claude/
```

### 6. Global CLAUDE.md (optional)
```bash
cp CLAUDE.md ~/CLAUDE.md
```

### 7. Profiles (optional)
Choose a profile based on your use case:
```bash
# Code development optimization
cp profiles/coding/CLAUDE.coding.md ~/CLAUDE.md

# Automation pipelines
cp profiles/CLAUDE.agents.md ~/CLAUDE.md

# Data analysis
cp profiles/CLAUDE.analysis.md ~/CLAUDE.md

# Maximum cost optimization
cp profiles/token-efficient/CLAUDE.md ~/CLAUDE.md
```

See `profiles/README.md` for detailed comparison.

## Customization

- **settings.json**: Add your `ANTHROPIC_BASE_URL` if using a custom endpoint
- **CLAUDE.md**: Adjust language, workflow, and tool preferences
- **rules/**: Add or modify rules per project by placing `.md` files in `~/.claude/rules/`

## Features

- **Multi-agent orchestration**: OMC (oh-my-claudecode) integration
- **Long-term memory**: claude-mem support (SQLite + Chroma)
- **Task tracking**: planning-with-files integration
- **Language rules**: TypeScript, Python, Golang best practices
- **Domain skills**: Article writing, market research, investor materials, etc.
- **Token optimization**: Optional profiles for cost-sensitive scenarios

## Sources

- Base rules: [everything-claude-code](https://github.com/stevenaldinger/everything-claude-code)
- Token-efficient profiles: [claude-token-efficient](https://github.com/drona23/claude-token-efficient)
- Skills: ECC (everything-claude-code) domain skills
- OMC: oh-my-claudecode multi-agent framework
