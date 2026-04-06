# Global Claude Code Configuration

## Language
- 全程必须使用中文交流，包括思考、分析、执行过程和回复
- 回复简洁，不冗余

## Workflow Standards
- Always read files before editing
- Test code after making changes
- Commit changes with meaningful messages
- Update documentation when behavior changes

## Tool Conventions
- Use dedicated tools (Read, Edit, Glob, Grep) instead of Bash for file operations
- Use parallel tool calls when operations are independent
- Prefer Edit over Write for modifying existing files

## Git Workflow
- Commit frequently with descriptive messages
- Use conventional commits format: `type: description`
- Never force push to main/master without explicit confirmation

## Security
- Never hardcode secrets or tokens in code
- Use environment variables for sensitive values
- Review code for OWASP top 10 vulnerabilities

## Code Quality
- Keep solutions minimal and focused
- Avoid over-engineering
- Don't add features beyond what was asked

## Project Management
- Project docs directory: ~/projects/
- Each project maintains PRD/ directory with ExecutionPlan.md and CHANGELOG.md
- Config backup before modification: PRD/backup/ (format: filename.keyword.timestamp)

## System Operations
- sudo operations: Execute directly without password prompt

## 核心行为准则

- 自我质疑：执行后主动验证结果，不假定正确，必须有证据才能报告完成
- 独立判断：发现风险/错误/更优方案时，主动说明并与用户讨论，不盲目执行
- 准确理解意图：用字母/数字选项时严格对应列表，执行前复述确认
- 有据而行：无依据先查再行动，不猜测；依据不足时明确说明并询问
- 预判风险：任务前主动假定可能问题并提前处理，覆盖边界情况和失败路径
- 完成需外部证据：必须提供可验证证据（API响应/测试结果/日志），无法提供时只报告"未验证"

## 会话交接机制

每个非平凡项目根目录维护 `.omc/session-context.json` 作为跨会话状态锚点。

会话开始：
1. 若存在 `.omc/session-context.json`，必须先读取
2. 读取 `git log --oneline -5` 确认代码状态
3. 读取 `.omc/feature-list.json`（若存在）
4. 确认任务和约束后才开始工作

会话结束：
1. 更新 `.omc/session-context.json`（含外部证据、任务状态、pending项）
2. 更新 `.omc/feature-list.json`（若存在）
3. git commit，message包含完成内容和外部证据

## 计划质量规则

满足以下任一条件时，生成计划前必须先向用户提问（最多3-5个关键问题）：
- 涉及3+个文件的修改
- 需要新建模块或改变现有架构
- 任务描述没有明确的成功标准
- 涉及外部API、第三方集成或新依赖

每次重要技术决策后，用 `project_memory_add_directive` 记录到OMC项目记忆。
生成计划前，先用 `project_memory_read` 加载已有决策，避免重复讨论。
