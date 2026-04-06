# 跨会话记忆失效诊断报告

**诊断时间**：2026-04-06 23:25
**问题发现者**：用户
**诊断者**：Claude (当前会话)

---

## 问题描述

**现象**：
```
时间线：
2026-03-31 → 项目完成，配置优化完毕
2026-04-06 → 用户回到项目（5天后）
         ↓
Claude 表现：完全不知道项目历史，从零开始分析
```

**用户的正确判断**：
> "这一问题暴露出另一个严重的问题，就是当项目有一定时间中止后，再次回到项目目录，上下文的管理没有连续，不能形成有效记忆，说明本项目不是最佳状态。"

---

## 数据分析

### 1. claude-mem 记录情况

**总记录数**：2,629 条
**当前项目记录**：278 条

**按会话统计**：
```
会话 2ffe6e77: 115 条（最多）
会话 4eb074fa: 104 条
会话 3310f3e7: 44 条
会话 9cd6c050: 10 条
会话 dbc6923c: 4 条
会话 597910ea: 1 条
```

**最后活动时间**：
- 会话 2ffe6e77 的最后记录：无时间戳（数据异常）
- 最近的记录都是关于 hooks、配置、插件状态

### 2. claude-mem hooks 配置

**已配置的 hooks**：
```json
✅ SessionStart - 启动 worker + 注入上下文
✅ UserPromptSubmit - 会话初始化
✅ PostToolUse - 捕获观察
✅ Stop - 生成摘要
✅ SessionEnd - 会话完成
```

**理论上应该工作**：hooks 配置完整，worker 进程运行正常

### 3. 当前会话状态

**Worker 进程**：
- PID: 7588（运行中）
- 启动时间：2026-04-06 19:53
- 运行时长：约 3.5 小时

**当前会话 ID**：
- 环境变量 `$CLAUDE_SESSION_ID` 为空
- 说明会话 ID 没有正确传递

---

## 根本原因分析

### 原因 1：会话上下文注入失败 ⚠️

**证据**：
1. claude-mem 有 278 条关于此项目的记录
2. 但我在会话开始时**没有看到任何历史上下文**
3. 我不知道项目已经完成了 7 个阶段
4. 我不知道当前配置是经过优化的

**可能的原因**：
- `UserPromptSubmit` hook 执行失败
- `session-init` 命令没有正确注入上下文
- 上下文注入了，但格式不对，我没有识别

### 原因 2：项目文档没有被主动加载 ⚠️

**证据**：
1. `PROJECT-SUMMARY.md` 存在且完整
2. 但我没有主动读取它
3. 我依赖 claude-mem 注入，而不是主动查找

**设计缺陷**：
- 依赖自动注入，而不是主动发现
- 没有"项目启动检查清单"
- 没有强制读取 PROJECT-SUMMARY.md 的机制

### 原因 3：OMC project-memory 为空 ⚠️

**证据**：
```json
{
  "techStack": { "languages": [], "frameworks": [] },
  "build": { "buildCommand": null }
}
```

**原因**：
- OMC memory 是为代码项目设计的
- 当前是配置项目，没有 package.json 等文件
- OMC 扫描不到任何技术栈信息

**影响**：
- OMC 无法提供项目上下文
- 完全依赖 claude-mem

### 原因 4：没有"项目恢复协议" ⚠️

**缺失的机制**：
1. 没有检测"这是一个已有项目"
2. 没有强制读取 PROJECT-SUMMARY.md
3. 没有验证 claude-mem 是否成功注入
4. 没有"上下文恢复失败"的降级方案

---

## 为什么前面的配置"不是最佳状态"

### 1. 过度依赖自动化

**设计假设**：
```
claude-mem 会自动注入历史 → Claude 就能记住一切
```

**实际情况**：
```
claude-mem 可能注入失败 → Claude 完全失忆
```

**问题**：
- 没有验证机制
- 没有降级方案
- 没有主动发现机制

### 2. 缺少"项目身份识别"

**当前状态**：
- 进入项目目录
- Claude 不知道这是什么项目
- 不知道项目历史
- 不知道项目状态

**应该有的机制**：
```bash
# 会话启动时
1. 检测 PROJECT-SUMMARY.md 是否存在
2. 如果存在，强制读取并显示摘要
3. 验证 claude-mem 是否注入了上下文
4. 如果没有，主动查询 claude-mem
```

### 3. 文档与记忆系统脱节

**当前架构**：
```
文档系统（Markdown）  ←→  记忆系统（SQLite）
     ↓                        ↓
  人类可读                 AI 可读
     ↓                        ↓
  手动维护                 自动捕获
```

**问题**：
- 两个系统独立运作
- 没有互相验证
- 没有一致性检查

**应该是**：
```
文档系统 ←→ 记忆系统
    ↓           ↓
  主要来源   辅助来源
    ↓           ↓
  强制读取   自动注入
```

---

## 对比：理想 vs 实际

### 理想情况（设计预期）

```
用户回到项目 5 天后：
1. SessionStart hook 触发
2. claude-mem 注入历史上下文
3. Claude 看到：
   "这是 claude-code-env 项目，已完成 7 个阶段，
    当前配置已优化，包含 claude-mem + OMC + planning..."
4. Claude 继续工作，无缝衔接
```

### 实际情况（本次会话）

```
用户回到项目 5 天后：
1. SessionStart hook 触发（可能）
2. claude-mem 注入失败或格式不对
3. Claude 看到：空白
4. Claude 从零开始分析，提出错误建议
5. 用户纠正："你忘记了项目历史"
6. Claude 才去读取文档
```

---

## 真正的问题

### 不是配置问题，是架构问题

**前面的分析认为**：
- ✅ claude-mem 配置正确
- ✅ hooks 配置正确
- ✅ 三系统互补
- ✅ 零冲突

**但忽略了**：
- ❌ 上下文注入的可靠性
- ❌ 注入失败的降级方案
- ❌ 项目身份识别机制
- ❌ 文档与记忆的一致性

### 核心缺陷：单点故障

```
整个记忆系统依赖于：
    claude-mem 的 UserPromptSubmit hook
              ↓
         如果失败
              ↓
        完全失忆
```

**没有**：
- 备用方案
- 验证机制
- 主动发现
- 降级策略

---

## 解决方案

### 方案 A：增强项目启动协议（推荐）

**实施步骤**：

#### 1. 创建项目启动 hook

在 `~/.claude/settings.json` 添加：

```json
"SessionStart": [
  {
    "matcher": "*",
    "hooks": [
      {
        "type": "command",
        "command": "if [ -f PROJECT-SUMMARY.md ]; then echo '\n=== 项目上下文 ==='; echo \"检测到 PROJECT-SUMMARY.md，建议立即读取\"; echo \"项目：$(head -1 PROJECT-SUMMARY.md)\"; echo \"状态：$(grep -A 1 '## 项目状态' PROJECT-SUMMARY.md | tail -1)\"; echo '==================\n'; fi",
        "timeout": 5
      }
    ]
  }
]
```

**效果**：
- 每次启动会话，自动检测 PROJECT-SUMMARY.md
- 显示项目名称和状态
- 提醒 Claude 立即读取

#### 2. 创建 CLAUDE.md 项目标识

在项目的 `CLAUDE.md` 顶部添加：

```markdown
# 项目标识
**项目名称**：Claude Code 环境优化项目
**项目状态**：已完成（2026-03-31）
**完整文档**：docs/PROJECT-SUMMARY.md

## 会话启动检查清单
- [ ] 读取 docs/PROJECT-SUMMARY.md
- [ ] 确认当前配置状态
- [ ] 了解三系统架构（claude-mem + OMC + planning）
```

**效果**：
- Claude 读取 CLAUDE.md 时会看到项目标识
- 强制执行启动检查清单

#### 3. 增强 claude-mem 验证

创建验证脚本 `scripts/verify-memory.sh`：

```bash
#!/bin/bash
# 验证 claude-mem 是否正确注入上下文

PROJECT_NAME="claude-code-env"
MEMORY_COUNT=$(sqlite3 ~/.claude-mem/claude-mem.db \
  "SELECT COUNT(*) FROM observations WHERE project = '$PROJECT_NAME';" 2>/dev/null)

if [ "$MEMORY_COUNT" -gt 0 ]; then
  echo "✅ claude-mem 已记录 $MEMORY_COUNT 条观察"
else
  echo "⚠️ claude-mem 没有此项目的记录"
fi
```

在 `SessionStart` hook 中调用：

```json
{
  "type": "command",
  "command": "bash scripts/verify-memory.sh",
  "timeout": 5
}
```

#### 4. 创建项目恢复命令

创建 skill `/project:resume`：

```markdown
---
name: project-resume
description: 恢复项目上下文，读取 PROJECT-SUMMARY 和验证记忆系统
---

# 项目恢复协议

1. 读取 docs/PROJECT-SUMMARY.md
2. 查询 claude-mem 记录数量
3. 检查 OMC project-memory 状态
4. 显示项目摘要和当前状态
5. 确认是否需要用户补充信息
```

---

### 方案 B：文档优先策略

**原则**：
- 文档是主要来源（Single Source of Truth）
- 记忆系统是辅助来源
- 强制读取文档，可选查询记忆

**实施**：

#### 1. 项目根目录创建 `.project-context`

```json
{
  "name": "claude-code-env",
  "type": "configuration",
  "status": "completed",
  "summary_file": "docs/PROJECT-SUMMARY.md",
  "last_updated": "2026-03-31",
  "phases_completed": 7,
  "memory_systems": ["claude-mem", "OMC", "planning-with-files"]
}
```

#### 2. SessionStart hook 强制读取

```bash
if [ -f .project-context ]; then
  echo "=== 项目上下文 ==="
  cat .project-context | jq -r '
    "项目：\(.name)",
    "类型：\(.type)",
    "状态：\(.status)",
    "完成阶段：\(.phases_completed)",
    "文档：\(.summary_file)"
  '
  echo "==================="
  echo "⚠️ 请立即读取 $(jq -r .summary_file .project-context)"
fi
```

#### 3. 验证机制

在 `UserPromptSubmit` hook 中：

```bash
# 检查是否已读取 PROJECT-SUMMARY
if [ -f .project-context ] && [ ! -f /tmp/claude-project-loaded-$CLAUDE_SESSION_ID ]; then
  echo "⚠️ 警告：检测到项目上下文文件，但尚未读取 PROJECT-SUMMARY.md"
  echo "建议：立即执行 /project:resume 或读取 docs/PROJECT-SUMMARY.md"
fi
```

---

### 方案 C：混合策略（最佳）

**结合 A + B**：

1. **SessionStart**：
   - 检测 `.project-context`
   - 显示项目摘要
   - 验证 claude-mem 状态
   - 提醒读取文档

2. **UserPromptSubmit**：
   - 检查是否已读取文档
   - 如果没有，显示警告
   - 提供快速恢复命令

3. **文档优先**：
   - PROJECT-SUMMARY.md 是主要来源
   - claude-mem 是辅助来源
   - 两者互相验证

4. **降级方案**：
   - claude-mem 失败 → 读取文档
   - 文档缺失 → 查询 claude-mem
   - 两者都失败 → 询问用户

---

## 实施优先级

### 立即实施（P0）

1. **创建 `.project-context` 文件**
   - 5 分钟
   - 立即生效

2. **添加 SessionStart hook**
   - 10 分钟
   - 下次会话生效

3. **在 CLAUDE.md 添加项目标识**
   - 5 分钟
   - 立即生效

### 短期实施（P1）

4. **创建 `/project:resume` skill**
   - 30 分钟
   - 提供手动恢复能力

5. **创建验证脚本**
   - 20 分钟
   - 增强可靠性

### 长期优化（P2）

6. **增强 claude-mem 注入验证**
   - 需要修改 claude-mem 插件
   - 或者创建 wrapper

7. **统一文档与记忆系统**
   - 设计一致性检查机制
   - 自动同步文档和记忆

---

## 测试计划

### 测试场景 1：正常恢复

```
1. 退出当前会话
2. 等待 5 分钟
3. 重新进入项目目录
4. 启动新会话
5. 验证：
   - 是否显示项目上下文？
   - 是否提醒读取文档？
   - 是否能快速恢复？
```

### 测试场景 2：claude-mem 失败

```
1. 停止 claude-mem worker
2. 启动新会话
3. 验证：
   - 是否有降级方案？
   - 是否能通过文档恢复？
   - 是否提示用户？
```

### 测试场景 3：文档缺失

```
1. 临时移除 PROJECT-SUMMARY.md
2. 启动新会话
3. 验证：
   - 是否能通过 claude-mem 恢复？
   - 是否提示文档缺失？
   - 是否询问用户？
```

---

## 结论

### 问题本质

**不是配置问题，是架构问题**：
- 过度依赖自动化
- 缺少验证机制
- 没有降级方案
- 单点故障风险

### 前面分析的局限

**前面的文档说**：
> "当前配置已是最佳状态"

**但忽略了**：
- 上下文注入的可靠性
- 跨会话恢复的鲁棒性
- 失败场景的处理

### 真正的"最佳状态"

**应该包括**：
1. ✅ 功能完整（已有）
2. ✅ 零冲突（已有）
3. ✅ 互补协作（已有）
4. ❌ 可靠恢复（缺失）← **本次发现**
5. ❌ 降级方案（缺失）← **本次发现**
6. ❌ 验证机制（缺失）← **本次发现**

---

## 下一步行动

### 建议用户

1. **立即实施 P0 项**：
   - 创建 `.project-context`
   - 添加 SessionStart hook
   - 更新 CLAUDE.md

2. **测试验证**：
   - 退出会话，重新进入
   - 验证是否能正确恢复

3. **更新文档**：
   - 在 PROJECT-SUMMARY.md 添加"阶段八：跨会话恢复优化"
   - 记录本次发现的问题和解决方案

### 需要 Claude 做的

1. **实施方案 C**
2. **创建测试用例**
3. **更新项目文档**
4. **验证效果**

---

**诊断完成时间**：2026-04-06 23:25
**下一步**：等待用户确认实施方案
