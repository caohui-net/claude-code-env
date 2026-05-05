# Claude Code Optimization Environment

A production-ready Claude Code environment template with verified plugins and configurations. Get an optimized development environment in minutes.

## What You Get

- **Multi-agent orchestration**: OMC (oh-my-claudecode) v4.11.5
- **Long-term memory**: claude-mem v10.6.2 (SQLite + Chroma)
- **Web automation**: Lightpanda v0.5.0 (headless browser)
- **Token optimization**: RTK v0.38.0 (60-90% savings on CLI operations)
- **Global rules**: TypeScript, Python, Golang best practices
- **Domain skills**: Planning, writing, research, investor materials
- **Task tracking**: planning-with-files integration

## Prerequisites

**Install these plugins first** (required for optimization):

### 1. OMC (oh-my-claudecode) v4.11.5

```bash
claude plugins install oh-my-claudecode@omc
```

Multi-agent orchestration framework. Enables autopilot, ultrawork, ralph, and team modes.

### 2. claude-mem v10.6.2

```bash
npm install -g claude-mem@10.6.2
```

Long-term memory system with SQLite + Chroma vector database.

**Note**: npm installation is only the first step. Complete setup requires:
- Worker configuration in `~/.claude/settings.json`
- Auto-start configuration in `~/.bashrc`
- Optional remote access setup

See `docs/install-log.md` for complete installation and configuration steps.

### 3. Lightpanda v0.5.0

```bash
claude plugins install lightpanda
```

Headless browser for web automation. 65-75% token savings vs curl for web content extraction.

See `docs/lightpanda-usage.md` for usage guide.

### 4. RTK (Rust Token Killer) v0.38.0

```bash
# Installation via cargo
cargo install rtk-cli

# Or download binary from releases
# See docs/rtk-integration.md for details
```

Token-optimized CLI proxy. 60-90% savings on git, npm, and other dev operations.

## Quick Start

### Step 1: Check Prerequisites

First, verify all required plugins and commands are installed:

```bash
git clone https://github.com/caohui-net/claude-code-env ~/projects/claude-code-env
cd ~/projects/claude-code-env
bash scripts/check-prerequisites.sh
```

If any required components are missing, install them following the [Prerequisites](#prerequisites) section above.

### Step 2: Install Configuration

Once all prerequisites are met, deploy the global configuration:

```bash
bash install.sh
```

This will:
- Copy rules and skills to `~/.claude/`
- Optionally merge hooks (use `--hooks minimal` or `--hooks omc`)
- Back up existing configurations
- Generate project context files

Then edit `~/.claude/settings.json` and set your `ANTHROPIC_AUTH_TOKEN`.

### Step 3: Verify Installation

Confirm everything is set up correctly:

```bash
bash scripts/verify-installation.sh
```

This checks:
- Plugin installations (OMC, claude-mem, Lightpanda, RTK)
- Configuration files in `~/.claude/`
- MCP server configurations
- Hook integrations

Expected output: All required components should show ✓ (green checkmark).

## What install.sh Does

`install.sh` deploys global configurations from this repository to `~/.claude/`:

- Copies `rules/` to `~/.claude/rules/` (common, TypeScript, Python, Golang)
- Copies `skills/` to `~/.claude/skills/`
- Optionally merges `hooks/` into `~/.claude/settings.json`
- Backs up existing configurations to `~/.claude/backup/`
- Verifies installation integrity
- Generates project context files

**Note**: `install.sh` does NOT install plugins. Plugins must be installed separately (see Prerequisites).

## Global Effect

Once installed, **ALL your Claude Code projects** benefit from:

- Optimized agent orchestration (OMC)
- Long-term memory across sessions (claude-mem)
- Token-efficient operations (RTK)
- Web automation capabilities (Lightpanda)
- Verified coding best practices (rules)
- Domain-specific skills (planning, writing, research)

No per-project configuration needed. The optimization is global.

## Project Status Files

- `project-state.json`: Project-level source of truth (phases, components, key files)
- `.omc/session-context.json`: Current/recent session state (session-level info)
- `.project-context.json`: Legacy compatibility file (auto-generated, do not edit)

## Manual Steps

If you prefer manual installation over `install.sh`:

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

## Verification

After installation, verify the setup:

```bash
bash scripts/verify-installation.sh
```

This checks:
- Plugin installations (OMC, claude-mem, Lightpanda, RTK)
- Configuration files in `~/.claude/`
- MCP server configurations
- Hook integrations

## Documentation

- `docs/PROJECT-SUMMARY.md`: Complete project history and phases
- `docs/install-log.md`: claude-mem setup and remote access
- `docs/lightpanda-usage.md`: Lightpanda usage guide
- `docs/lightpanda-vs-curl-comparison.md`: When to use Lightpanda vs curl
- `docs/rtk-integration.md`: RTK setup and usage
- `docs/codex-evaluation-report-2026-05-02.md`: Project evaluation results

## Sources

- Base rules: [everything-claude-code](https://github.com/stevenaldinger/everything-claude-code)
- Token-efficient profiles: [claude-token-efficient](https://github.com/drona23/claude-token-efficient)
- Skills: ECC (everything-claude-code) domain skills
- OMC: oh-my-claudecode multi-agent framework
- claude-mem: Long-term memory system
- Lightpanda: Headless browser MCP server
- RTK: Rust Token Killer CLI proxy

## License

MIT

## Contributing

Contributions welcome. Please ensure:
- All plugins are tested and version-pinned
- Documentation is updated
- `install.sh` is tested on clean installations
- Changes are verified with `scripts/verify-installation.sh`
