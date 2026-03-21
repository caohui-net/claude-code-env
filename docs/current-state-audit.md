# 当前环境状态审计报告

**审计日期**: 2026-03-21
**目的**: 记录全新安装开始前的已有状态，作为基线参考

---

## 1. Claude Code 本体

| 项目 | 值 |
|------|-----|
| 版本 | 2.1.80 |
| 安装方式 | npm global (`~/.npm-global`) |
| 安装命令 | `npm install -g @anthropic-ai/claude-code` |
| 二进制路径 | `~/.local/bin/claude` |
| 包路径 | `~/.npm-global/lib/node_modules/@anthropic-ai/claude-code` |

---

## 2. ~/.claude/settings.json

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-ant-oat01-...",
    "ANTHROPIC_BASE_URL": "https://code.newcli.com/claude/ultra",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": 1
  },
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

**注意**：
- 无 `hooks` 字段
- 无 `mcpServers` 字段（MCP 配置在 `~/.mcp.json`）
- 使用自定义 `ANTHROPIC_BASE_URL`（非官方端点）

---

## 3. MCP 服务器配置 (~/.mcp.json)

全局 MCP 配置，3 个服务器，均通过 `npx` 按需运行：

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "exa": {
      "command": "npx",
      "args": ["-y", "exa-mcp-server"],
      "env": { "EXA_API_KEY": "..." }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "..." }
    }
  }
}
```

**状态**: 会话中已激活，提供 context7 文档查询、exa 网络搜索、github 操作能力。

---

## 4. 插件系统

### 4.1 Marketplace 状态

| Marketplace | 来源 | 安装方式 | 状态 |
|-------------|------|----------|------|
| claude-plugins-official | `anthropics/claude-plugins-official` (GitHub) | Claude Code 首次使用自动拉取 | **缓存已下载**，非手动安装 |

**重要说明**：`claude-plugins-official` 是 Claude Code 内置的默认 marketplace，
首次使用插件功能时自动 git clone 到 `~/.claude/plugins/marketplaces/`，不需要手动操作。

### 4.2 已下载的官方插件（仅缓存，未激活安装）

以下插件文件存在于 marketplace 缓存中，**但未通过 `claude plugin install` 激活**：

**功能类插件**：
| 插件名 | 功能 | Commands | Skills |
|--------|------|----------|--------|
| commit-commands | Git 工作流 | commit, commit-push-pr, clean_gone | - |
| code-review | 代码审查 | code-review | - |
| pr-review-toolkit | PR 审查 | review-pr | - |
| feature-dev | 功能开发 | feature-dev | - |
| hookify | Hooks 管理 | hookify, configure, list | writing-rules |
| claude-code-setup | 环境配置 | - | claude-automation-recommender |
| claude-md-management | CLAUDE.md 管理 | revise-claude-md | claude-md-improver |
| plugin-dev | 插件开发 | create-plugin | 7个开发技能 |
| skill-creator | Skill 创建 | - | skill-creator |

**LSP 类插件**（语言服务器）：
clangd, csharp, gopls, jdtls, kotlin, lua, php, pyright, ruby, rust-analyzer, swift, typescript

**输出风格类插件**：
explanatory-output-style, learning-output-style

**其他**：agent-sdk-dev, code-simplifier, example-plugin, frontend-design, playground, ralph-loop, security-guidance

### 4.3 External 插件（外部集成，仅目录存在）

asana, context7, discord, fakechat, firebase, github, gitlab, greptile, laravel-boost, linear, playwright, serena, slack, stripe, supabase, telegram

### 4.4 Blocklist

```json
[
  {"plugin": "code-review@claude-plugins-official", "reason": "just-a-test"},
  {"plugin": "fizz@testmkt-marketplace", "reason": "security"}
]
```

---

## 5. 当前激活的 Skills（Bundled，内置于 CLI）

| Skill | 触发场景 |
|-------|----------|
| update-config | 配置 settings.json/hooks/权限变更 |
| simplify | 代码审查和简化 |
| loop | 定时循环任务 (`/loop`) |
| claude-api | 使用 Anthropic SDK/API 开发 |

**说明**：这些 skills 是 Claude Code 本体内置的 bundled skills，无需安装任何插件即可使用。

---

## 6. Rules

`~/.claude/rules/common/` 下有 8 个文件（2026-03-21 由 install.sh 安装）：

| 文件 | 来源 |
|------|------|
| agents.md | everything-claude-code/rules/common/ |
| coding-style.md | everything-claude-code/rules/common/ |
| git-workflow.md | everything-claude-code/rules/common/ |
| hooks.md | everything-claude-code/rules/common/ |
| patterns.md | everything-claude-code/rules/common/ |
| performance.md | everything-claude-code/rules/common/ |
| security.md | everything-claude-code/rules/common/ |
| testing.md | everything-claude-code/rules/common/ |

---

## 7. CLAUDE.md 状态

| 文件 | 状态 |
|------|------|
| `~/CLAUDE.md` | **不存在** |
| 项目级 `CLAUDE.md` | 各项目自有 |

---

## 8. everything-claude-code 项目

| 项目 | 值 |
|------|-----|
| 路径 | `~/projects/everything-claude-code/` |
| 性质 | 普通 git 仓库（手动 clone），非插件系统安装 |
| 是否激活为 marketplace | **否**（历史上曾安装过，现已清理） |
| 用途 | 作为 rules/hooks/mcp 配置的参考源 |

---

## 9. 项目级 Hooks

`~/projects/moltbook/.claude/settings.json` 中有 PreToolUse hook：
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Write",
      "hooks": [{"type": "command", "command": "node -e ..."}],
      "description": "Allow all file writes in moltbook project"
    }]
  }
}
```

---

## 总结：从零开始需要安装的内容

| 组件 | 操作 | 优先级 |
|------|------|--------|
| Claude Code CLI | `npm install -g @anthropic-ai/claude-code` | 必须 |
| settings.json | 配置 token/base_url | 必须 |
| MCP 服务器 | 创建 `~/.mcp.json` + 配置 3 个服务器 | 高 |
| Rules | 复制到 `~/.claude/rules/common/` | 高 |
| Hooks | 配置到 settings.json | 中 |
| 全局 CLAUDE.md | 创建 `~/CLAUDE.md` | 中 |
| 插件（按需） | `claude plugin install <name>` | 按需 |
