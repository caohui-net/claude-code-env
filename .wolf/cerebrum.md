# Cerebrum

> OpenWolf's learning memory. Updated automatically as the AI learns from interactions.
> Do not edit manually unless correcting an error.
> Last updated: 2026-05-05

## User Preferences

<!-- How the user likes things done. Code style, tools, patterns, communication. -->

## Key Learnings

- **Project:** claude-code-env
- **Description:** Personal Claude Code environment configuration for quick setup on new machines.

## Do-Not-Repeat

<!-- Mistakes made and corrected. Each entry prevents the same mistake recurring. -->
<!-- Format: [YYYY-MM-DD] Description of what went wrong and what to do instead. -->

### [2026-05-05] PreToolUse:Bash Hook 多层转义错误

**问题：** settings.json 中 PreToolUse:Bash hook 使用 `node -e` 执行 JavaScript 代码，正则表达式中的 `\b` 单词边界需要多层转义（JSON → bash → node），导致 `[eval]:1` 语法错误。

**根本原因：** 
- JSON: `\\\\b` → bash: `\\b` → node: `\b` 
- 在 JavaScript 字符串上下文中，`\b` 是退格符，不是正则边界
- 转义层级错配导致语法错误

**正确做法：**
- 避免在 hook 中使用需要复杂转义的正则模式
- 用完整匹配代替单词边界：`/(npm run dev|pnpm dev|...)/` 而非 `/(npm run dev\\\\b|...)/`
- Hook 代码保持简单，减少转义层级

### [2026-05-05] 验证修复的正确方法

**问题：** 多次声称问题已解决，但实际问题仍存在。隔离测试通过，但真实执行环境仍失败。

**根本原因：**
- 只在隔离环境测试（手动执行 hook 脚本）
- 未在真实执行环境验证（Claude Code 实际调用 hook）
- 假设隔离测试通过 = 问题解决

**正确做法：**
- 修改后必须在真实环境测试（让用户实际执行命令）
- 不能只依赖隔离测试
- 声称"问题解决"前，必须看到用户确认错误消失
- 承认不确定性：说"应该修复了，请测试确认"而非"已修复"

## Decision Log

<!-- Significant technical decisions with rationale. Why X was chosen over Y. -->
