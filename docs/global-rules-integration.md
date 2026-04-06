# 全局规则集成分析

## 规则对比

### 1. 项目管理规则

**新规则**：
- 项目文档总目录：C:\Users\Administrator\Documents\My Project
- PRD/ 目录维护
- 配置文件备份机制

**当前环境**：
- 无项目文档总目录规定
- 无 PRD 目录要求

**冲突检测**：✅ 无冲突
**建议**：适配 Linux 路径，添加到全局配置

---

### 2. 开发工作流

**新规则**：
- Plan → TDD → Code Review → Commit

**当前环境**：
- OMC 已有 planner, tdd-guide, code-reviewer agents
- 已有类似工作流

**冲突检测**：✅ 无冲突（完全一致）
**建议**：已覆盖，无需添加

---

### 3. TDD 强制流程

**新规则**：
- RED → GREEN → IMPROVE
- 覆盖率 ≥ 80%

**当前环境**：
- `~/.claude/rules/common/testing.md` 已有 TDD 要求
- 已要求 80% 覆盖率

**冲突检测**：✅ 无冲突（已存在）
**建议**：已覆盖，无需添加

---

### 4. 编码规范

**新规则**：
- 不可变性
- 文件组织（200-400行）
- 错误处理
- 输入验证

**当前环境**：
- `~/.claude/rules/common/coding-style.md` 已有不可变性要求
- 已有文件组织规范（800行上限）

**冲突检测**：⚠️ 部分重叠
- 文件大小：新规则更严格（400 vs 800）

**建议**：保持当前 800 行上限（更灵活）

---

### 5. 安全检查清单

**新规则**：
- 6 项安全检查

**当前环境**：
- `~/.claude/rules/common/security.md` 已有安全规范

**冲突检测**：✅ 无冲突（已覆盖）
**建议**：已覆盖，无需添加

---

### 6. Git 规范

**新规则**：
- 提交格式：`<type>: <description>`
- PR 流程

**当前环境**：
- `~/.claude/rules/common/git-workflow.md` 已有
- 全局 CLAUDE.md 已强制 commit + push

**冲突检测**：✅ 无冲突（已存在）
**建议**：已覆盖，无需添加

---

### 7. Agent 使用规则

**新规则**：
- 立即使用 planner/code-reviewer/tdd-guide/architect

**当前环境**：
- `~/.claude/rules/common/agents.md` 已有相同规则

**冲突检测**：✅ 无冲突（已存在）
**建议**：已覆盖，无需添加

---

### 8. 模型路由

**新规则**：
- Haiku/Sonnet/Opus 分工

**当前环境**：
- `~/.claude/rules/common/performance.md` 已有模型选择策略

**冲突检测**：✅ 无冲突（已存在）
**建议**：已覆盖，无需添加

---

### 9. 特殊规则

**新规则**：
- sudo 直接执行
- 中文回复
- 并行执行
- 测试覆盖率 80%

**当前环境**：
- 中文回复：全局 CLAUDE.md 已配置
- 并行执行：已有规则
- 测试覆盖率：已有规则
- sudo：未配置

**冲突检测**：⚠️ sudo 规则缺失
**建议**：添加 sudo 规则

---

### 10. OMC 多 Agent 编排

**新规则**：
- OMC v4.9.0
- 工作流技能
- 状态持久化

**当前环境**：
- OMC 已安装并配置
- 状态文件已存在

**冲突检测**：✅ 无冲突（已存在）
**建议**：已覆盖，无需添加

---

## 需要添加的规则

### 1. 项目管理规则（适配 Linux）

```markdown
## Project Management
- Project docs directory: ~/projects/
- Each project maintains PRD/ directory:
  - ExecutionPlan.md
  - CHANGELOG.md
- Config backup before modification:
  - Location: PRD/backup/
  - Format: filename.keyword.timestamp
```

### 2. sudo 规则

```markdown
## System Operations
- sudo operations: Execute directly without password prompt
```

---

## 集成建议

### 方案：最小化添加

**添加到 `/home/caohui/CLAUDE.md`**：
1. 项目管理规则（适配 Linux 路径）
2. sudo 规则

**不添加**（已存在）：
- TDD 流程
- 编码规范
- 安全检查
- Git 规范
- Agent 使用
- 模型路由
- 并行执行
- 测试覆盖率

---

**状态**：分析完成
**结论**：90% 规则已存在，只需添加 2 项新规则
