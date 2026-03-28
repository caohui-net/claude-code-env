# 最终优化方案：分层启用策略

## 核心原则

**不是"全装全开"，而是"按需分层"**

## 当前状态分析

你已有：
- ✅ OMC（主控层）- 提供自动编排
- ✅ claude-mem（记忆层）- 提供跨会话记忆
- ✅ planning-with-files（任务层）- 文件已安装

## 问题

我刚才添加的 hooks 会导致：
1. **PreToolUse 高频触发** - 每次工具执行都显示 30 行计划
2. **UserPromptSubmit 信息过载** - 50 行计划 + 20 行进度 + claude-mem 记忆
3. **PostToolUse 双重提醒** - planning 提醒 + mem 观察捕获

## 推荐配置

### 方案 A：最小化 Hooks（推荐）

**只保留 Stop hook**，移除其他 planning hooks：

优点：
- 零噪声
- 手动调用 `/plan-zh` 启动规划
- 会话结束时检查完成状态
- claude-mem 正常工作

适合：
- 依赖 OMC 自动编排
- 只在复杂任务时手动启用 planning
- 重视清爽的工作流

### 方案 B：轻量化 Hooks

保留 Stop + 简化的 UserPromptSubmit：

```json
"UserPromptSubmit": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "if [ -f task_plan.md ]; then echo '[planning] 活跃计划，请读取 task_plan.md'; fi",
        "timeout": 3
      },
      {
        "type": "command",
        "command": "claude-mem session-init...",
        "timeout": 60
      }
    ]
  }
]
```

移除：
- PreToolUse（高频触发）
- PostToolUse（重复提醒）

优点：
- 轻量提醒
- 不干扰工作流
- 保留核心价值

## 我的建议

**采用方案 A**，原因：

1. **OMC 已经提供任务编排**
   - 不需要 planning-with-files 自动提醒

2. **按需启用更灵活**
   - 复杂任务：手动 `/plan-zh`
   - 简单任务：直接用 OMC

3. **claude-mem 是核心**
   - 解决跨会话记忆才是你的主要需求
   - 不应被 planning 提醒干扰

## 下一步

需要我帮你：
1. 回退到原配置（只保留 claude-mem hooks）
2. 或者应用方案 A（添加 Stop hook）
3. 或者应用方案 B（轻量化配置）

你希望采用哪个方案？
