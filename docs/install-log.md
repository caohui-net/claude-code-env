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

### 自动启动配置（~/.bashrc）

**v2（2026-03-22 修复）**：改为全异步非阻塞方式，解决 bash 启动卡顿问题：

```bash
# claude-mem: persistent memory for Claude Code
alias claude-mem='CLAUDE_PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/thedotmack/plugin" bun "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
# auto-start claude-mem worker on shell init (async, non-blocking)
{
  if ! curl -sf --max-time 1 http://localhost:37777/api/health > /dev/null 2>&1; then
    PATH="$HOME/.local/bin:$PATH" \
    CLAUDE_PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/thedotmack/plugin" \
      bun "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs" > /dev/null 2>&1 &
  fi
} &
```

逻辑：整个检测+启动逻辑用 `{ } &` 包裹放入后台，bash 初始化不受任何阻塞。

**启动性能基准（2026-03-22 实测，WSL2）**：

| 阶段 | 耗时 |
|------|------|
| bash 交互式 shell 启动 | **22ms** |
| worker `initialized=true` | ~510ms |
| worker `mcpReady=true`（含 mcp-server 连接）| ~520ms |

三次冷启动测量：520ms / 512ms / 511ms，均值 **514ms**。

### 已知问题与修复记录（2026-03-22）

#### 问题 1：`uvx` 找不到
- **现象**：`Connection failed: Executable not found in $PATH: "uvx"`
- **原因**：Worker 进程继承的 PATH 不包含 `~/.local/bin`
- **修复**：创建 symlink `sudo ln -sf ~/.local/bin/uvx /usr/local/bin/uvx`，并在 bashrc 启动命令中显式注入 `PATH="$HOME/.local/bin:$PATH"`

#### 问题 2：`mcpReady: false`（mcp-server.cjs 路径硬编码）
- **现象**：Worker 运行但 `mcpReady` 永远为 false，`MCP server connection failed`
- **原因**：`worker-service.cjs` 第 68286 行 `__dirname` 被硬编码为开发者 Mac 路径 `/Users/alexnewman/...`，导致 `node /Users/alexnewman/.../mcp-server.cjs` 文件不存在
- **修复**：将该行改为本机路径：
  ```
  var __dirname = "/home/caohui/.claude/plugins/marketplaces/thedotmack/plugin/scripts"
  ```
- **注意**：插件更新后此修复会被覆盖，需重新应用

#### 问题 3：bash 启动卡顿
- **现象**：新开终端需等待数秒才出现提示符
- **原因**：原 bashrc 中 `curl` 检测为同步阻塞，worker 未运行时等待连接超时
- **修复**：改为 `{ } &` 异步后台执行，bash 启动时间从数秒降至 **22ms**

### 注意事项

- worker-service.cjs 必须用 **bun** 运行（不能用 node，ES Module 兼容问题）
- `uvx` 需在 PATH 中，已通过 `/usr/local/bin/uvx` symlink 保证
- 插件更新后需重新修复 worker-service.cjs 第 68286 行的 `__dirname` 硬编码
- 手动重启：`kill $(pgrep -f worker-service.cjs) && PATH="$HOME/.local/bin:$PATH" CLAUDE_PLUGIN_ROOT=~/.claude/plugins/marketplaces/thedotmack/plugin bun ~/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs &`
