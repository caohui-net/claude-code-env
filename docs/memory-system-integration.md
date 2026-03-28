# claude-mem + planning-with-files 融合配置

## 配置完成时间
2026-03-28

## 系统架构

### claude-mem（长期记忆）
- **职责**：自动捕获工具使用 → AI 压缩 → 跨会话检索
- **数据**：SQLite + Chroma 向量数据库
- **优势**：自动化、语义搜索、跨项目记忆

### planning-with-files（当前任务）
- **职责**：结构化任务追踪 → 防止目标漂移
- **数据**：task_plan.md + findings.md + progress.md
- **优势**：人类可读、强制注意力、显式追踪

## Hooks 配置

### UserPromptSubmit
1. **planning-with-files**：检测 task_plan.md，提醒读取
2. **claude-mem**：初始化会话上下文

### PreToolUse（新增）
- **planning-with-files**：工具执行前显示计划（前30行）
- **触发条件**：Write|Edit|Bash

### PostToolUse
1. **planning-with-files**：文件修改后提醒更新进度
2. **claude-mem**：捕获观察记录

### Stop
1. **planning-with-files**：检查任务完成状态
2. **claude-mem**：生成会话摘要

## 互补效果

| 场景 | claude-mem | planning-with-files |
|------|-----------|-------------------|
| 新任务开始 | 注入历史经验 | 创建任务结构 |
| 执行过程 | 自动记录观察 | 显示当前计划 |
| 文件修改 | 捕获变更 | 提醒更新进度 |
| 会话结束 | AI 压缩摘要 | 验证完成状态 |
| 下次启动 | 恢复上下文 | 继续未完成任务 |

## 使用方式

### 启动规划
```
/plan-zh
```

### 查看状态
```
/plan:status
```

### 搜索历史
```
使用 claude-mem 的语义搜索功能
```

## 备份位置
原配置已备份至：`~/.claude/settings.json.backup-*`

## 验证
- ✅ UserPromptSubmit：planning 提醒 + mem 初始化
- ✅ PreToolUse：显示计划（新增）
- ✅ PostToolUse：更新提醒 + 观察捕获
- ✅ Stop：完成检查 + 摘要生成
