# Claude Code 环境优化项目 - Codex 评估报告

**评估日期**: 2026-05-02  
**评估工具**: OpenAI Codex v0.128.0 (gpt-5.5)  
**Session ID**: 019de98b-2d46-7600-9147-1585d7435429  
**Token 使用**: 92,102

---

## 总体结论

项目方向合理，核心架构"OMC 主控 + claude-mem 长期记忆 + planning-with-files 任务追踪 + rules/skills/profiles 扩展"是清晰的，文档量也足够支撑复盘。

**但当前状态更像"个人环境演进记录 + 模板仓库"的混合体，不是一个真正可一键复现的环境产品。**

主要风险集中在：
- 配置事实源不一致
- hooks 引用外部脚本
- MCP 配置分裂
- 跨会话状态文件漂移
- 安全边界偏宽

### 静态验证结果

✅ `jq` 校验 JSON 通过  
✅ `install.sh` 和 planning shell 脚本语法通过  
✅ `claude-mem-proxy.js` 语法通过  
✅ planning Python 脚本 AST 解析通过

---

## 关键问题

### 1. 安装脚本与 README 宣称不一致

**问题描述**:
- README 把 `install.sh` 描述为一键设置入口
- 但脚本只复制 settings、rules、skills，并提示用户手动合并 hooks/MCP
- `install.sh:16` 写着"Existing settings.json found. Merging hooks field"，但实际没有 merge 逻辑，只打印提示

**影响**: 新机器部署结果与文档预期偏离

**证据**:
- README.md:21
- install.sh:58
- install.sh:16

### 2. hooks 配置不能直接作为可用模板

**问题描述**:
- `hooks/hooks.json` 里大量引用 `${CLAUDE_PLUGIN_ROOT}/scripts/hooks/*.js`
- 但仓库没有这些脚本
- 已有审计文档也明确指出直接安装会失败

**结论**: hooks 作为"参考配置"可以，作为"推荐直接合并配置"不可靠

**证据**:
- hooks/hooks.json:50, 74, 140
- env-check-2026-03-21.md:127

### 3. MCP 配置分裂

**问题描述**:
- 仓库有通用 MCP 参考 `mcp-servers.json`
- 实际项目级 `.mcp.json` 只配置了 Lightpanda
- README 又建议把 MCP 放到 `~/.claude/settings.json` 的 `mcpServers` 下
- 早期审计文档说 MCP 在 `~/.mcp.json`

**影响**: 增加安装者的判断成本，需要明确"全局 MCP、项目 MCP、参考模板"三者的优先级

**证据**:
- mcp-servers.json:2
- .mcp.json:2
- README.md:55

### 4. 跨会话记忆系统有设计补强，但状态文件漂移

**问题描述**:
- 项目已识别 claude-mem 依赖 `sessionId` 的失败模式
- 后续用 `.project-context.json` 和 `.omc/session-context.json` 做降级锚点（正确方向）
- 但当前两个锚点不一致：
  - `.project-context.json`: 2026-03-31、7 个阶段
  - `.omc/session-context.json`: 2026-05-02、13 个阶段

**影响**: 削弱跨会话恢复的可信度

**证据**:
- final-summary.md:32
- .project-context.json:6
- .omc/session-context.json:3

### 5. 文档完整但时序和状态不干净

**问题描述**:
- `PROJECT-SUMMARY.md` 内容丰富，但阶段顺序混乱（10、11、12 后再回到 9、8）
- 文档顶部时间线仍写到 2026-04-12，但后面已有 2026-05-02 的内容
- RTK 段落写"提交：待提交"，但 git log 显示已有提交 `4cdbb1f`

**影响**: 典型状态漂移，降低文档可信度

**证据**:
- PROJECT-SUMMARY.md:161, 331
- PROJECT-SUMMARY.md:5
- PROJECT-SUMMARY.md:319

### 6. 多代理协同文档存在"可用性断层"

**问题描述**:
- 规则中声明 agents 位于 `~/.claude/agents/`
- 但仓库没有 agents 目录
- 安装脚本也不安装 agents
- `skills/omc-reference` 提供参考，但不能证明新环境具备这些 agents

**结论**: 多代理"理念和参考文档完整"，但模板仓库没有端到端安装验证

**证据**:
- rules/common/agents.md:5

### 7. 安全边界需要收紧

**问题描述**:
- `claude-mem-proxy.js` 监听 `0.0.0.0`，转发到本地 37777
- 若运行在可被局域网或公网访问的机器上，会暴露记忆 Web Viewer，且没有鉴权
- `CLAUDE.md` 写了"sudo operations: Execute directly without password prompt"

**影响**: 对个人环境方便，但作为模板默认规则风险较高

**证据**:
- claude-mem-proxy.js:28
- CLAUDE.md:79

---

## 分项评估

| 项目 | 评分 | 结论 |
|---|---:|---|
| 架构设计 | 7/10 | 分层合理，但个人安装状态和模板职责混杂 |
| 配置质量 | 5/10 | JSON 语法正确，hooks/MCP 可用性不足 |
| 文档完整性 | 8/10 | 覆盖面广，但状态、时序、事实源不一致 |
| 可维护性 | 6/10 | 目录清晰，文档过多且重复，缺少单一维护入口 |
| 功能完整性 | 6/10 | 机制齐全，但端到端恢复和多代理安装未完全产品化 |
| 风险控制 | 5/10 | 存在远程暴露、sudo 默认规则、运行时文件跟踪问题 |

**平均分**: 6.2/10

---

## 改进建议

### 1. 建立单一事实源

以 `.omc/session-context.json` 或 `docs/PROJECT-SUMMARY.md` 其中之一为主，生成或同步 `.project-context.json`，不要手动维护三份状态。

### 2. 拆分配置

- `settings.min.json`：纯安全最小模板
- `settings.hooks.safe.json`：只包含仓库内可运行 hooks
- `settings.hooks.omc.json`：明确依赖 OMC 插件
- `mcp/reference.json` 与 `.mcp.json` 明确区分

### 3. 修正 `install.sh`

要么真正合并 hooks/MCP，要么删除"merge"措辞；增加 `--dry-run`、备份、验证步骤。

### 4. 补充安装文档

补一个 `INSTALL.md` 和 `TROUBLESHOOTING.md`。当前 README 适合快速开始，但不够解释：
- hooks 依赖
- MCP 放置位置
- claude-mem/OMC/Lightpanda/RTK 的安装前提

### 5. 收紧安全默认值

- `claude-mem-proxy` 默认监听 `127.0.0.1`，需要远程访问时显式传参
- 删除或弱化 sudo 自动执行规则

### 6. 清理版本控制状态

`.omc/state/checkpoints/...` 已被 git 跟踪，即使 `.omc/.gitignore` 后续排除了 checkpoints，已跟踪文件仍会保留。应从索引移除运行时文件。

### 7. 增加端到端验证脚本

检查：
- settings JSON
- hooks 脚本存在性
- MCP server 命令可执行性
- Lightpanda 路径
- planning scripts
- claude-mem proxy 端口
- `.project-context.json` 状态一致性

---

## 总结

当前项目不是"坏架构"，而是"好架构还没收敛成稳定发行版"。

**优先修复**（收益最大）：
1. 配置事实源统一
2. 安装脚本修正
3. hooks 依赖明确化

**后续优化**：
4. 安全默认值收紧
5. 文档补充和清理
6. 端到端验证脚本
7. 版本控制状态清理
