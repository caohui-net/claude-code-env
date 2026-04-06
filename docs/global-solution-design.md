# 全局项目上下文恢复方案

**设计时间**：2026-04-06 23:35
**问题**：跨会话记忆失效
**根因**：claude-mem session-init 被跳过（缺少 sessionId）
**目标**：全局可复用的上下文恢复机制

---

## 测试结果

### claude-mem 失效原因

```
[2026-04-06 23:32:04.451] [WARN] session-init: No sessionId provided,
skipping (Codex CLI or unknown platform)
```

**问题**：
- claude-mem 依赖 `sessionId` 环境变量
- 当前环境没有提供
- 导致上下文注入被跳过

**影响**：
- 记录存在（278 条）
- 但没有注入到会话
- Claude 完全失忆

---

## 全局解决方案

### 设计原则

1. **不依赖 claude-mem 自动注入**
   - 因为它依赖 sessionId，不可靠

2. **文档驱动**
   - 项目文档是 Single Source of Truth
   - 自动检测并提醒读取

3. **全局可复用**
   - 配置在 `~/.claude/` 全局目录
   - 所有项目自动生效

4. **零依赖**
   - 不依赖特定插件
   - 纯 bash + 文件检测

---

## 方案架构

```
全局配置（~/.claude/）
├── hooks/
│   └── project-context-detector.sh  ← 项目上下文检测器
├── rules/
│   └── project-recovery.md          ← 项目恢复协议
└── settings.json
    └── SessionStart hook             ← 自动触发检测

项目配置（每个项目）
├── .project-context.json             ← 项目元数据
├── PROJECT-SUMMARY.md                ← 项目总览
└── CLAUDE.md                         ← 项目规则
```

---

## 实施步骤

### 步骤 1：创建全局检测脚本

**文件**：`~/.claude/hooks/project-context-detector.sh`

```bash
#!/bin/bash
# 项目上下文检测器
# 在每次会话启动时自动运行

PROJECT_CONTEXT_FILE=".project-context.json"
PROJECT_SUMMARY="PROJECT-SUMMARY.md"
CLAUDE_MD="CLAUDE.md"

# 检测项目上下文文件
if [ -f "$PROJECT_CONTEXT_FILE" ]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           🔍 检测到项目上下文                              ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    # 读取项目元数据
    if command -v jq &> /dev/null; then
        PROJECT_NAME=$(jq -r '.name // "未知项目"' "$PROJECT_CONTEXT_FILE")
        PROJECT_STATUS=$(jq -r '.status // "未知"' "$PROJECT_CONTEXT_FILE")
        PROJECT_TYPE=$(jq -r '.type // "未知"' "$PROJECT_CONTEXT_FILE")
        SUMMARY_FILE=$(jq -r '.summary_file // "PROJECT-SUMMARY.md"' "$PROJECT_CONTEXT_FILE")
        PHASES=$(jq -r '.phases_completed // "N/A"' "$PROJECT_CONTEXT_FILE")
        LAST_UPDATED=$(jq -r '.last_updated // "未知"' "$PROJECT_CONTEXT_FILE")

        echo "  项目名称：$PROJECT_NAME"
        echo "  项目类型：$PROJECT_TYPE"
        echo "  项目状态：$PROJECT_STATUS"
        echo "  完成阶段：$PHASES"
        echo "  最后更新：$LAST_UPDATED"
        echo ""
        echo "  📄 完整文档：$SUMMARY_FILE"
        echo ""
        echo "  ⚠️  建议：立即读取 $SUMMARY_FILE 以恢复项目上下文"
        echo ""
    else
        echo "  ⚠️  检测到 $PROJECT_CONTEXT_FILE"
        echo "  建议：立即读取 PROJECT-SUMMARY.md"
        echo ""
    fi

    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

# 检测 PROJECT-SUMMARY.md
elif [ -f "$PROJECT_SUMMARY" ]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           📋 检测到项目总览文档                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    # 提取项目名称（第一行）
    PROJECT_NAME=$(head -1 "$PROJECT_SUMMARY" | sed 's/^# //')
    echo "  项目：$PROJECT_NAME"
    echo ""
    echo "  📄 文档：$PROJECT_SUMMARY"
    echo "  ⚠️  建议：立即读取以了解项目背景"
    echo ""
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

# 检测 CLAUDE.md
elif [ -f "$CLAUDE_MD" ]; then
    # 检查是否有项目标识
    if grep -q "项目标识\|Project Identity\|项目名称\|Project Name" "$CLAUDE_MD"; then
        echo ""
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║           📝 检测到项目配置                                ║"
        echo "╚════════════════════════════════════════════════════════════╝"
        echo ""
        echo "  📄 配置文件：$CLAUDE_MD"
        echo "  ⚠️  建议：读取 CLAUDE.md 了解项目规则"
        echo ""
        echo "╚════════════════════════════════════════════════════════════╝"
        echo ""
    fi
fi

# 检测 claude-mem 状态（可选）
if [ -d "$HOME/.claude-mem" ] && command -v sqlite3 &> /dev/null; then
    PROJECT_DIR=$(basename "$(pwd)")
    MEMORY_COUNT=$(sqlite3 "$HOME/.claude-mem/claude-mem.db" \
        "SELECT COUNT(*) FROM observations WHERE project LIKE '%$PROJECT_DIR%';" 2>/dev/null || echo "0")

    if [ "$MEMORY_COUNT" -gt 0 ]; then
        echo "  💾 claude-mem：已记录 $MEMORY_COUNT 条观察"
        echo "     （注意：自动注入可能失效，建议手动查询）"
        echo ""
    fi
fi
```

**权限**：
```bash
chmod +x ~/.claude/hooks/project-context-detector.sh
```

---

### 步骤 2：配置全局 SessionStart Hook

**文件**：`~/.claude/settings.json`

在 `hooks` 部分添加：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/project-context-detector.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

**注意**：
- 如果已有 SessionStart hook，添加到数组中
- 确保在 claude-mem 的 hook 之后执行

---

### 步骤 3：创建项目上下文模板

**文件**：`~/.claude/templates/.project-context.json`

```json
{
  "name": "项目名称",
  "type": "code|configuration|documentation|research",
  "status": "active|completed|archived",
  "summary_file": "docs/PROJECT-SUMMARY.md",
  "last_updated": "2026-04-06",
  "phases_completed": 0,
  "memory_systems": ["claude-mem", "OMC", "planning-with-files"],
  "tech_stack": {
    "languages": [],
    "frameworks": [],
    "tools": []
  },
  "notes": "项目简短描述"
}
```

**使用方法**：
```bash
# 在新项目中
cp ~/.claude/templates/.project-context.json .project-context.json
# 编辑内容
```

---

### 步骤 4：创建全局项目恢复协议

**文件**：`~/.claude/rules/common/project-recovery.md`

```markdown
# 项目上下文恢复协议

## 触发条件

当检测到以下文件之一时，自动触发：
1. `.project-context.json`
2. `PROJECT-SUMMARY.md`
3. `CLAUDE.md`（包含项目标识）

## 恢复步骤

### 1. 读取项目元数据

**优先级**：
1. `.project-context.json` - 结构化元数据
2. `PROJECT-SUMMARY.md` - 完整项目总览
3. `CLAUDE.md` - 项目规则和配置

### 2. 验证记忆系统

检查以下记忆系统的状态：
- claude-mem：查询观察记录数量
- OMC memory：检查 `.omc/project-memory.json`
- planning-with-files：检查 `task_plan.md`

### 3. 显示项目摘要

向用户显示：
- 项目名称和类型
- 项目状态
- 完成阶段
- 最后更新时间
- 建议阅读的文档

### 4. 降级方案

如果自动检测失败：
- 提示用户手动读取 PROJECT-SUMMARY.md
- 提供快速恢复命令（如 `/project:resume`）
- 询问用户是否需要补充信息

## 最佳实践

### 项目启动时

1. **立即读取 PROJECT-SUMMARY.md**
   - 了解项目背景
   - 确认当前状态
   - 查看完成阶段

2. **验证配置**
   - 检查 CLAUDE.md 规则
   - 确认技术栈
   - 了解工作流程

3. **查询记忆系统**
   - claude-mem：搜索相关决策
   - OMC memory：查看项目上下文
   - planning：检查未完成任务

### 项目工作中

1. **保持文档更新**
   - 重大决策记录到 PROJECT-SUMMARY.md
   - 配置变更更新 CLAUDE.md
   - 阶段完成更新 .project-context.json

2. **定期验证一致性**
   - 文档与实际状态一致
   - 记忆系统与文档一致
   - 配置与实现一致

### 项目完成时

1. **更新项目状态**
   ```json
   {
     "status": "completed",
     "last_updated": "2026-04-06"
   }
   ```

2. **归档文档**
   - 完整的 PROJECT-SUMMARY.md
   - 最终的配置文件
   - 关键决策记录

3. **清理临时文件**
   - 删除 task_plan.md
   - 清理临时脚本
   - 保留核心文档
```

---

### 步骤 5：为当前项目创建 .project-context.json

**文件**：`/home/caohui/projects/claude-code-env/.project-context.json`

```json
{
  "name": "claude-code-env",
  "type": "configuration",
  "status": "completed",
  "summary_file": "docs/PROJECT-SUMMARY.md",
  "last_updated": "2026-03-31",
  "phases_completed": 7,
  "memory_systems": ["claude-mem", "OMC", "planning-with-files"],
  "tech_stack": {
    "languages": [],
    "frameworks": [],
    "tools": ["claude-mem", "oh-my-claudecode", "planning-with-files"]
  },
  "notes": "Claude Code 环境优化项目 - 构建具备长期记忆、多代理协同、跨会话恢复能力的开发环境",
  "github": "https://github.com/caohui-net/claude-code-env",
  "purpose": "环境模板项目，为所有项目提供可复用的配置"
}
```

---

## 部署到全局环境

### 文件清单

需要复制到全局环境的文件：

```
~/.claude/
├── hooks/
│   └── project-context-detector.sh      ← 新建
├── rules/common/
│   └── project-recovery.md              ← 新建
├── templates/
│   └── .project-context.json            ← 新建
└── settings.json                        ← 修改（添加 SessionStart hook）
```

### 部署脚本

**文件**：`scripts/deploy-global-solution.sh`

```bash
#!/bin/bash
# 部署全局项目上下文恢复方案

set -e

echo "开始部署全局项目上下文恢复方案..."

# 1. 创建目录
mkdir -p ~/.claude/hooks
mkdir -p ~/.claude/templates
mkdir -p ~/.claude/rules/common

# 2. 复制检测脚本
echo "复制项目上下文检测器..."
cp hooks/project-context-detector.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/project-context-detector.sh

# 3. 复制恢复协议
echo "复制项目恢复协议..."
cp rules/project-recovery.md ~/.claude/rules/common/

# 4. 复制模板
echo "复制项目上下文模板..."
cp templates/.project-context.json ~/.claude/templates/

# 5. 备份 settings.json
echo "备份 settings.json..."
cp ~/.claude/settings.json ~/.claude/settings.json.backup-$(date +%Y%m%d-%H%M%S)

# 6. 更新 settings.json（添加 SessionStart hook）
echo "更新 settings.json..."
# 这里需要手动编辑，或使用 jq

echo ""
echo "✅ 部署完成！"
echo ""
echo "下一步："
echo "1. 手动编辑 ~/.claude/settings.json"
echo "   添加 SessionStart hook（见文档）"
echo "2. 重启 Claude Code"
echo "3. 测试：进入任意项目目录，启动新会话"
echo ""
```

---

## 测试计划

### 测试 1：当前项目恢复

```bash
# 1. 创建 .project-context.json
cd /home/caohui/projects/claude-code-env
# （文件已在步骤 5 创建）

# 2. 退出当前会话
exit

# 3. 重新进入项目
cd /home/caohui/projects/claude-code-env
claude

# 4. 验证
# 应该看到：
# ╔════════════════════════════════════════════════════════════╗
# ║           🔍 检测到项目上下文                              ║
# ╚════════════════════════════════════════════════════════════╝
#   项目名称：claude-code-env
#   项目状态：completed
#   ...
```

### 测试 2：新项目

```bash
# 1. 创建测试项目
mkdir -p ~/test-project
cd ~/test-project

# 2. 复制模板
cp ~/.claude/templates/.project-context.json .

# 3. 编辑内容
# 修改项目名称、状态等

# 4. 启动会话
claude

# 5. 验证
# 应该看到项目上下文提示
```

### 测试 3：无上下文项目

```bash
# 1. 进入没有上下文文件的目录
cd ~/some-random-dir

# 2. 启动会话
claude

# 3. 验证
# 不应该看到任何提示（正常行为）
```

---

## 优势

### vs claude-mem 自动注入

| 特性 | claude-mem | 全局方案 |
|------|-----------|---------|
| 依赖 | sessionId 环境变量 | 文件检测 |
| 可靠性 | 不可靠（可能跳过） | 可靠（纯 bash） |
| 可见性 | 不可见（后台注入） | 可见（显式提示） |
| 降级 | 无 | 有（手动读取） |
| 全局性 | 需要插件 | 纯配置 |

### vs 手动读取

| 特性 | 手动读取 | 全局方案 |
|------|---------|---------|
| 自动化 | 无 | 有 |
| 一致性 | 依赖记忆 | 强制提醒 |
| 效率 | 低（每次手动） | 高（自动检测） |
| 遗漏风险 | 高 | 低 |

---

## 维护

### 更新检测脚本

```bash
# 编辑
vim ~/.claude/hooks/project-context-detector.sh

# 测试
bash ~/.claude/hooks/project-context-detector.sh

# 部署到其他机器
scp ~/.claude/hooks/project-context-detector.sh user@host:~/.claude/hooks/
```

### 更新项目上下文

```bash
# 编辑项目元数据
vim .project-context.json

# 更新时间戳
jq '.last_updated = "2026-04-06"' .project-context.json > tmp && mv tmp .project-context.json
```

---

## 扩展

### 集成 claude-mem 查询

在检测脚本中添加：

```bash
# 查询 claude-mem 最近的观察
if [ "$MEMORY_COUNT" -gt 0 ]; then
    echo "  最近的决策："
    sqlite3 "$HOME/.claude-mem/claude-mem.db" \
        "SELECT title FROM observations
         WHERE project LIKE '%$PROJECT_DIR%' AND type = 'decision'
         ORDER BY created_at_epoch DESC LIMIT 3;" 2>/dev/null | \
        sed 's/^/    - /'
fi
```

### 集成 OMC memory

```bash
# 检查 OMC project-memory
if [ -f ".omc/project-memory.json" ]; then
    TECH_STACK=$(jq -r '.techStack.languages[]' .omc/project-memory.json 2>/dev/null | tr '\n' ', ')
    if [ -n "$TECH_STACK" ]; then
        echo "  技术栈：$TECH_STACK"
    fi
fi
```

---

## 总结

### 解决的问题

1. ✅ claude-mem session-init 失效
2. ✅ 跨会话记忆断裂
3. ✅ 项目上下文丢失
4. ✅ 依赖不可靠的自动注入

### 核心优势

1. **零依赖**：纯 bash + 文件检测
2. **全局可复用**：一次配置，所有项目生效
3. **可靠性高**：不依赖 sessionId
4. **可见性强**：显式提示，不是黑盒
5. **有降级方案**：自动失败 → 手动读取

### 适用场景

- ✅ 环境模板项目
- ✅ 多项目管理
- ✅ 团队协作
- ✅ 长期维护的项目
- ✅ 需要跨会话恢复的场景

---

**设计完成时间**：2026-04-06 23:45
**下一步**：实施部署
