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

**目标**：安装 claude-mem，实现跨会话上下文持久化记忆。（初装 v10.6.1，已更新至 v10.6.2）

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
- **原因**：v10.6.1 的 `worker-service.cjs` 中 `__dirname` 被硬编码为开发者 Mac 路径 `/Users/alexnewman/...`
- **修复**：手动修改该行为本机路径（临时方案）；**v10.6.2 已在上游原生修复，更新后无需任何手动操作**

#### 问题 3：bash 启动卡顿
- **现象**：新开终端需等待数秒才出现提示符
- **原因**：原 bashrc 中 `curl` 检测为同步阻塞，worker 未运行时等待连接超时
- **修复**：改为 `{ } &` 异步后台执行，bash 启动时间从数秒降至 **22ms**

#### 问题 4：Stop hook 可能中断执行（2026-03-22）

- **现象**：Stop hook 在某些场景下退出码非零，Claude Code 将其解释为"block stop"，导致执行被中断并反复重试
- **根本原因**（两层）：
  1. **误导性 ERROR 日志**：当会话最后一个 assistant 消息为工具调用（`tool_use` 类型，无文本内容）时，`T9()` 函数找不到文本消息，记录 `Missing last_assistant_message` ERROR。这只是日志问题，summarize 实际仍能正常完成。
  2. **超时竞态**：旧配置 Stop hook 外部 timeout=120s，但内部 HTTP fetch timeout=300s。API 响应慢时，Claude Code 先于 fetch 完成强制 KILL 进程，导致非零退出码。
- **修复**（`~/.claude/settings.json` Stop hook）：
  - timeout 从 120s 降至 30s
  - 命令前加 `sleep 1`（给 transcript 文件写入缓冲时间，避免竞态）
  - 设置 `CLAUDE_MEM_HEALTH_TIMEOUT_MS=5000`（加速健康检查，从默认 300s 降至 5s）
  - 命令末尾加 `; exit 0`（**核心修复**：无论命令是否成功，退出码始终为 0，彻底防止 Stop hook 中断执行）
- **当前 Stop hook 命令**：
  ```
  _R="${CLAUDE_PLUGIN_ROOT}"; [ -z "$_R" ] && _R="$HOME/.claude/plugins/marketplaces/thedotmack/plugin"; sleep 1; CLAUDE_MEM_HEALTH_TIMEOUT_MS=5000 node "$_R/scripts/bun-runner.js" "$_R/scripts/worker-service.cjs" hook claude-code summarize; exit 0
  ```
- **验证**：worker 运行时 exit=0 ✓，worker 不可用时 exit=0 ✓，完整命令 exit=0 ✓

---

### 注意事项

- worker-service.cjs 必须用 **bun** 运行（不能用 node，ES Module 兼容问题）
- `uvx` 需在 PATH 中，已通过 `/usr/local/bin/uvx` symlink 保证
- 手动重启：`kill $(pgrep -f worker-service.cjs) && PATH="$HOME/.local/bin:$PATH" CLAUDE_PLUGIN_ROOT=~/.claude/plugins/marketplaces/thedotmack/plugin bun ~/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs &`
- **Stop hook 规则**：任何 Stop hook 命令末尾必须加 `; exit 0`，防止 hook 失败阻断 Claude Code 执行

---

### Web Viewer 访问方案（2026-03-29）

**官方限制**：
前端硬编码 `CLAUDE_MEM_WORKER_HOST: "127.0.0.1"`，直接访问仅支持 localhost。

**解决方案：反向代理**

创建了轻量级 Node.js 反向代理（无额外依赖），支持从任意 IP 访问。

**代理脚本位置**：
```
scripts/claude-mem-proxy.js
```

**启动代理**：
```bash
# 启动代理（监听 0.0.0.0:38888，代理到 127.0.0.1:37777）
node scripts/claude-mem-proxy.js 38888 &

# 或指定其他端口
node scripts/claude-mem-proxy.js 8080 &
```

**访问方式**：
```bash
# 本地访问（原始方式）
http://127.0.0.1:37777/

# 通过代理访问（支持任意 IP）
http://127.0.0.1:38888/
http://<your-ip>:38888/
```

**验证**：
```bash
# 1. 启动代理
node scripts/claude-mem-proxy.js 38888 &

# 2. 验证代理工作
curl -s http://127.0.0.1:38888/health

# 3. 通过 IP 访问
curl -s http://172.25.22.35:38888/api/observations?limit=1 | jq '.items | length'

# 4. 浏览器访问 http://<your-ip>:38888/
```

**验证结果（2026-03-29 02:52）**：
```bash
# 1. 代理监听确认
ss -tlnp | grep 38888
# 输出：0.0.0.0:38888 LISTEN

# 2. JS文件大小验证
curl -s http://172.25.22.35:38888/viewer-bundle.js | wc -c
# 输出：267119 (261KB)

# 3. API数据验证
curl -s http://172.25.22.35:38888/api/observations?limit=1 | jq -r '.items[0].id'
# 输出：2443 (正常返回数据)

# 4. HTML页面验证
curl -s http://172.25.22.35:38888/ | grep -c "<!DOCTYPE html>"
# 输出：1 (页面正常)
```

**上游改动验证**：
```bash
# MD5校验：viewer-bundle.js 与备份完全相同
md5sum ~/.claude/plugins/marketplaces/thedotmack/plugin/ui/viewer-bundle.js*
# 9be10695434e9db2dc3df7485ba51646 (两个文件MD5相同)
```

**结论**：
- ✅ 上游代码零改动
- ✅ 解决方案完全独立
- ✅ 本地访问：直接访问 37777 端口
- ✅ 远程访问：通过代理访问 38888 端口
- ✅ 跨机器访问：支持从任意机器访问
- ✅ 无额外依赖：仅使用 Node.js 内置模块
- ✅ 上游更新不影响功能
