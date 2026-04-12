# Claude Code Profiles

可选的 CLAUDE.md 配置文件，针对不同使用场景优化。

## 使用方法

### 方式 1：替换全局配置
```bash
cp profiles/CLAUDE.coding.md ~/CLAUDE.md
```

### 方式 2：项目级配置
```bash
cp profiles/CLAUDE.coding.md your-project/CLAUDE.md
```

### 方式 3：与主配置组合
Claude Code 会读取多个 CLAUDE.md 文件（全局 + 项目级），规则会叠加。

---

## 可用 Profiles

### CLAUDE.coding.md
**适用场景**：代码开发、代码审查、调试、重构

**特点**：
- 代码优先，解释其次
- 禁止过度工程化
- 禁止推测性功能
- 简洁输出格式

**何时使用**：纯代码项目，需要快速迭代

---

### CLAUDE.agents.md
**适用场景**：自动化流水线、多智能体系统、批量任务

**特点**：
- 极简输出
- 结构化响应
- 适合解析
- 减少噪声

**何时使用**：CI/CD 流水线、自动化脚本、agent 循环

---

### CLAUDE.analysis.md
**适用场景**：数据分析、研究、报告生成

**特点**：
- 结构化分析
- 清晰结论
- 数据优先
- 减少修饰

**何时使用**：数据科学项目、研究任务、分析报告

---

### token-efficient/
**适用场景**：极致成本优化

**特点**：
- 最小化输出 token
- 基准测试显示减少 63% 输出
- 适合高频调用场景

**何时使用**：
- 每天 100+ 次调用
- 成本敏感项目
- 自动化流水线

**不适合**：
- 单次查询
- 探索性工作
- 需要详细解释的场景

---

## 性能对比

| Profile | 输出减少 | 适用场景 | 成本影响 |
|---------|---------|---------|---------|
| 默认（无 profile） | 0% | 通用 | 基准 |
| coding | ~30% | 代码开发 | -30% |
| agents | ~50% | 自动化 | -50% |
| token-efficient | ~63% | 高频调用 | -63% |

---

## 组合使用

可以同时使用多个配置：

```bash
# 全局：通用规则
cp CLAUDE.md ~/CLAUDE.md

# 项目：代码优化
cp profiles/CLAUDE.coding.md ~/projects/my-app/CLAUDE.md
```

规则会叠加，项目级配置优先级更高。

---

## 来源

- **token-efficient profiles**: https://github.com/drona23/claude-token-efficient
- **主配置**: 本项目整合的最佳实践
