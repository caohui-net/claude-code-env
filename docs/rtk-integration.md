# RTK (Rust Token Killer) 集成文档

## 项目信息

- **名称**: RTK (Rust Token Killer)
- **版本**: v0.38.0
- **GitHub**: https://github.com/rtk-ai/rtk
- **Stars**: 39.7k
- **许可**: MIT License

## 项目简介

RTK 是一个高性能 CLI 代理工具，通过智能过滤和压缩命令输出，减少 LLM token 消耗 60-90%。

## 核心特性

### 1. Token 节省效果

| 操作 | 标准 Token | RTK Token | 节省比例 |
|------|-----------|----------|---------|
| ls/tree | 2,000 | 400 | -80% |
| cat/read | 40,000 | 12,000 | -70% |
| git status | 3,000 | 600 | -80% |
| git diff | 10,000 | 2,500 | -75% |
| cargo test | 25,000 | 2,500 | -90% |
| pytest | 8,000 | 800 | -90% |
| **30分钟会话总计** | **118,000** | **23,900** | **-80%** |

### 2. 工作原理

```
标准流程: Claude → shell → git (2000 tokens)
RTK流程:  Claude → RTK → git (200 tokens, 节省 90%)
```

**四大优化策略**：
1. **智能过滤** - 移除注释、空白、样板代码
2. **分组聚合** - 按目录/类型聚合相似项
3. **智能截断** - 保留关键上下文，删除冗余
4. **去重** - 合并重复日志行并计数

### 3. 自动重写 Hook

RTK 通过 Claude Code 的 PreToolUse hook 透明拦截 Bash 命令：

```bash
用户输入: git status
实际执行: rtk git status
AI 看到: 简洁的输出（节省 80% token）
```

**零开销**：
- 命令重写对 AI 完全透明
- <10ms 执行开销
- 100% 自动化，无需手动调用

## 安装记录

### 安装步骤

```bash
# 1. 下载安装
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

# 2. 验证安装
rtk --version  # rtk 0.38.0

# 3. 初始化集成
rtk init -g --auto-patch

# 4. 验证集成
rtk init -g --show
```

### 安装结果

- ✅ 二进制文件: `/home/caohui/.local/bin/rtk`
- ✅ Hook 脚本: `rtk hook claude`
- ✅ 配置文件: `/home/caohui/.claude/RTK.md`
- ✅ 全局引用: `~/.claude/CLAUDE.md` 添加 `@RTK.md`
- ✅ Settings: `~/.claude/settings.json` 添加 hook
- ✅ 过滤器模板: `/home/caohui/.config/rtk/filters.toml`

## 集成配置

### Hook 配置

RTK hook 已添加到 `~/.claude/settings.json`:

```json
{
  "hooks": {
    "preToolUse": [
      {
        "tool": "Bash",
        "command": "rtk hook claude"
      }
    ]
  }
}
```

### RTK.md 内容

位置: `/home/caohui/.claude/RTK.md`

包含：
- Meta 命令使用说明（gain, discover, proxy）
- 安装验证步骤
- Hook 使用说明
- 名称冲突警告

### CLAUDE.md 引用

全局 CLAUDE.md 添加了 `@RTK.md` 引用，自动加载 RTK 配置。

## 支持的命令

### 文件操作
- `rtk ls` - Token 优化的目录树
- `rtk read` - 智能文件读取
- `rtk find` - 紧凑的查找结果
- `rtk grep` - 分组搜索结果

### Git 操作
- `rtk git status` - 紧凑状态
- `rtk git log` - 单行提交
- `rtk git diff` - 压缩差异
- `rtk git add/commit/push` - 简化输出

### 测试运行器
- `rtk jest` - Jest 紧凑输出
- `rtk pytest` - Python 测试（-90%）
- `rtk cargo test` - Rust 测试（-90%）
- `rtk go test` - Go 测试（-90%）

### 构建和 Lint
- `rtk tsc` - TypeScript 错误分组
- `rtk cargo build` - Cargo 构建（-80%）
- `rtk cargo clippy` - Cargo clippy（-80%）
- `rtk ruff check` - Python linting（-80%）

### 包管理器
- `rtk pnpm list` - 紧凑依赖树
- `rtk pip list` - Python 包列表

### 容器
- `rtk docker ps` - 紧凑容器列表
- `rtk docker logs` - 去重日志
- `rtk kubectl pods` - 紧凑 pod 列表

## 使用场景

### 场景 1：Git 工作流

**标准输出**（git status，15行，~300 tokens）：
```
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   src/main.rs
        modified:   Cargo.toml

no changes added to commit (use "git add" and/or "git commit -a")
```

**RTK 输出**（3行，~50 tokens）：
```
* main...origin/main
~ Modified: 2 files
   src/main.rs, Cargo.toml
```

**节省**: 83% token

### 场景 2：测试运行

**标准输出**（cargo test 失败，200+ 行）：
```
running 15 tests
test utils::test_parse ... ok
test utils::test_format ... ok
test core::test_process ... FAILED
...
[详细堆栈跟踪]
...
```

**RTK 输出**（~20 行）：
```
FAILED: 1/15 tests
  test_process: assertion failed at core.rs:42
[full output: ~/.local/share/rtk/tee/1707753600_cargo_test.log]
```

**节省**: 90% token

### 场景 3：目录浏览

**标准输出**（ls -la，45行，~800 tokens）：
```
drwxr-xr-x  15 user staff 480 ...
-rw-r--r--   1 user staff 1234 ...
...
```

**RTK 输出**（12行，~150 tokens）：
```
my-project/
 +-- src/ (8 files)
 |   +-- main.rs
 +-- Cargo.toml
```

**节省**: 81% token

## 与 Lightpanda 的协同

### 互补关系

| 工具 | 用途 | Token 节省 |
|------|------|-----------|
| **Lightpanda** | 网页内容获取 | 65-75% |
| **RTK** | 命令输出过滤 | 60-90% |
| **组合效果** | 全方位优化 | 70-85% 平均 |

### 使用场景分工

**Lightpanda 场景**：
- 网页内容提取
- 链接收集
- 表单分析
- 市场研究

**RTK 场景**：
- Git 操作
- 测试运行
- 构建输出
- 日志分析

**组合场景**：
- 抓取竞品网站（Lightpanda）→ 分析代码仓库（RTK）
- 获取文档页面（Lightpanda）→ 运行示例代码（RTK）

## Token 分析工具

### 查看节省统计

```bash
rtk gain                # 摘要统计
rtk gain --graph        # ASCII 图表（最近30天）
rtk gain --history      # 最近命令历史
rtk gain --daily        # 按天分解
rtk gain --all --format json  # JSON 导出
```

### 发现优化机会

```bash
rtk discover            # 查找错过的节省机会
rtk discover --all --since 7  # 所有项目，最近7天
```

### 会话分析

```bash
rtk session             # 显示最近会话的 RTK 采用率
```

## 配置文件

### 主配置

位置: `~/.config/rtk/config.toml`

```toml
[hooks]
exclude_commands = ["curl", "playwright"]  # 跳过重写的命令

[tee]
enabled = true          # 失败时保存原始输出（默认: true）
mode = "failures"       # "failures", "always", 或 "never"
```

### 自定义过滤器

位置: `~/.config/rtk/filters.toml`

可以添加自定义命令过滤规则。

## 验证测试

### 基本功能测试

```bash
# 1. 版本检查
rtk --version
# 输出: rtk 0.38.0

# 2. Git 命令测试
rtk git status
# 输出: 简洁的状态（3行）

# 3. 集成状态检查
rtk init -g --show
# 输出: 所有检查通过
```

### Hook 测试

重启 Claude Code 后，直接使用标准命令：

```bash
git status  # 自动重写为 rtk git status
ls -la      # 自动重写为 rtk ls
```

## 性能指标

### 执行开销

- **延迟**: <10ms
- **内存**: 单一二进制，~5MB
- **CPU**: 极低

### Token 节省

- **平均节省**: 70-80%
- **最高节省**: 90%（测试输出）
- **最低节省**: 60%（文件读取）

## 限制和注意事项

### 1. Hook 作用域

**仅适用于 Bash 工具调用**：
- ✅ `git status` → 自动重写
- ❌ Claude Code 内置工具（Read, Grep, Glob）→ 不经过 hook

**解决方案**：
- 使用 shell 命令：`cat`, `grep`, `find`
- 或直接调用：`rtk read`, `rtk grep`, `rtk find`

### 2. 名称冲突

另一个项目 "rtk" (Rust Type Kit) 存在于 crates.io。

**验证方法**：
```bash
rtk gain  # 应该工作
# 如果失败，说明安装了错误的包
```

### 3. 原始输出访问

当 RTK 过滤导致信息丢失时，可以访问完整输出：

```bash
# RTK 自动保存失败命令的完整输出
~/.local/share/rtk/tee/<timestamp>_<command>.log
```

## 卸载

```bash
# 1. 移除 hook 和配置
rtk init -g --uninstall

# 2. 移除二进制
rm ~/.local/bin/rtk

# 3. 移除配置（可选）
rm -rf ~/.config/rtk
rm -rf ~/.local/share/rtk
```

## 相关资源

- **官方网站**: https://www.rtk-ai.app
- **GitHub**: https://github.com/rtk-ai/rtk
- **文档**: https://www.rtk-ai.app/guide
- **Discord**: https://discord.gg/RySmvNF5kF

## 集成时间线

- **2026-05-02**: 安装 RTK v0.38.0
- **2026-05-02**: 初始化 Claude Code 集成
- **2026-05-02**: 验证功能测试通过

## 下一步

1. ✅ 重启 Claude Code 激活 hook
2. ⏳ 使用一段时间后运行 `rtk gain` 查看实际节省
3. ⏳ 根据需要调整 `config.toml` 排除特定命令
4. ⏳ 定期运行 `rtk discover` 发现优化机会
