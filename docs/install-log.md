# 安装流程记录

**格式说明**：每个安装步骤记录操作命令、验证方法、验证结果、以及任何注意事项。

---

## 步骤列表

| # | 组件 | 状态 | 完成日期 |
|---|------|------|----------|
| 1 | Claude Code CLI | 待记录 | - |
| 2 | settings.json 基础配置 | 待记录 | - |
| 3 | MCP 服务器 (context7) | 待记录 | - |
| 4 | MCP 服务器 (exa) | 待记录 | - |
| 5 | MCP 服务器 (github) | 待记录 | - |
| 6 | Rules 安装 | 待记录 | - |
| 7 | Hooks 配置 | 待记录 | - |
| 8 | 全局 CLAUDE.md | 待记录 | - |
| 9 | 插件（按需） | 待记录 | - |
| 10 | claude-mem 持久记忆插件 | ✅ 已完成 | 2026-03-22 |

---

<!-- 每完成一步，在下方追加对应章节 -->

## 步骤 10：claude-mem 持久记忆插件

**目标**：安装 claude-mem v10.6.1，实现跨会话上下文持久化记忆。

**来源**：https://github.com/thedotmack/claude-mem

### 前置条件验证

| 依赖 | 版本 | 状态 |
|------|------|------|
| Node.js | v24.13.1 | ✅ |
| Bun | 1.3.9 | ✅ |
| SQLite | 内置 | ✅ |

### 安装命令

```bash
# 1. 克隆仓库
git clone --depth=1 https://github.com/thedotmack/claude-mem.git /tmp/claude-mem

# 2. 同步到 Claude 插件目录
mkdir -p ~/.claude/plugins/marketplaces/thedotmack
rsync -av --delete --exclude=.git --exclude=bun.lock --exclude=package-lock.json \
  --exclude=node_modules /tmp/claude-mem/ ~/.claude/plugins/marketplaces/thedotmack/

# 3. 安装依赖
cd ~/.claude/plugins/marketplaces/thedotmack && npm install

# 4. 启动 worker daemon（后台服务）
CLAUDE_PLUGIN_ROOT=~/.claude/plugins/marketplaces/thedotmack/plugin \
  bun ~/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs --daemon
```

### 验证结果

```bash
curl http://localhost:37777/api/health
# 返回：{"status":"ok","version":"development","pid":4047,"platform":"linux",...}
```

### 文件位置

| 路径 | 说明 |
|------|------|
| `~/.claude/plugins/marketplaces/thedotmack/` | 插件主目录 |
| `~/.claude-mem/claude-mem.db` | SQLite 数据库 |
| `~/.claude-mem/settings.json` | 插件配置（自动生成） |
| `~/.claude-mem/logs/` | Worker 日志 |

### Hooks 注册

已写入 `~/.claude/settings.json`，包含以下 5 个生命周期钩子：

| Hook | 触发条件 | 功能 |
|------|---------|------|
| `SessionStart` | startup/clear/compact | 启动 worker、加载历史上下文 |
| `UserPromptSubmit` | 每次用户输入 | 初始化会话 |
| `PostToolUse` | 每次工具调用后 | 记录 observation |
| `Stop` | 响应结束时 | 生成会话摘要 |
| `SessionEnd` | 会话结束时 | 标记会话完成 |

### 关键配置（~/.claude-mem/settings.json）

| 参数 | 值 | 说明 |
|------|----|------|
| `CLAUDE_MEM_MODEL` | claude-sonnet-4-5 | 处理记忆的 AI 模型 |
| `CLAUDE_MEM_WORKER_PORT` | 37777 | Worker HTTP 服务端口 |
| `CLAUDE_MEM_DATA_DIR` | ~/.claude-mem | 数据存储目录 |
| `CLAUDE_MEM_CONTEXT_OBSERVATIONS` | 50 | 注入上下文的 observation 数量 |

### 注意事项

- worker-service.cjs 必须用 **bun** 运行（不能用 node，ES Module 兼容问题）
- bun-runner.js 会自动查找 bun 可执行路径，适配 PATH 未刷新的情况
- Worker 以 daemon 模式运行，重启 Claude Code 后需重新启动 worker
- 建议将 daemon 启动命令加入 shell 启动脚本（.bashrc/.zshrc）
