# 一键部署计划

## 目标
用户访问 GitHub 仓库后，通过一个命令完成全部环境配置

## 当前状态（2026-03-29）

### 已完成 ✅
- OMC 核心已安装并配置
- claude-mem 已安装并配置
- ECC 语言规范已集成（TypeScript, Python, Golang）
- ECC 领域技能已集成（6个）
- 文档已完善

### 缺失部分 ⚠️

#### 1. 配置文件未纳入仓库
**需要添加的文件**：
- `~/.claude/CLAUDE.md` → `config/CLAUDE.md`
- `~/.claude/settings.json` → `config/settings.json`
- `~/.claude/rules/` → `config/rules/`
- `~/.claude/skills/` → `config/skills/`
- `~/.bashrc` 中的 claude-mem 配置 → `config/bashrc-snippet.sh`

#### 2. 依赖安装脚本缺失
**需要创建**：
- `install.sh` - 主安装脚本
- `scripts/install-omc.sh` - OMC 安装
- `scripts/install-claude-mem.sh` - claude-mem 安装
- `scripts/install-ecc.sh` - ECC 集成

#### 3. 环境检测脚本缺失
**需要创建**：
- `scripts/check-env.sh` - 环境验证
- `scripts/test-integration.sh` - 集成测试

## 部署计划

### 阶段一：配置文件收集

**任务**：
1. 导出当前工作配置到仓库
   ```bash
   mkdir -p config/{rules,skills}
   cp ~/.claude/CLAUDE.md config/
   cp ~/.claude/settings.json config/
   cp -r ~/.claude/rules/* config/rules/
   cp -r ~/.claude/skills/* config/skills/
   grep "claude-mem" ~/.bashrc > config/bashrc-snippet.sh
   ```

2. 添加 .gitignore 排除敏感信息
   ```
   config/settings.json  # 可能包含 API keys
   .env
   *.key
   ```

3. 创建配置模板
   - `config/settings.json.template` - 移除敏感信息
   - `config/CLAUDE.md.template` - 通用配置

### 阶段二：安装脚本开发

**主脚本**：`install.sh`
```bash
#!/bin/bash
# 1. 检查前置条件（Claude Code, git, node）
# 2. 安装 OMC
# 3. 安装 claude-mem
# 4. 集成 ECC
# 5. 复制配置文件
# 6. 运行验证测试
```

**子脚本**：
- `scripts/install-omc.sh` - OMC 安装逻辑
- `scripts/install-claude-mem.sh` - claude-mem 编译安装
- `scripts/install-ecc.sh` - ECC 选择性集成
- `scripts/check-env.sh` - 环境验证

### 阶段三：测试和验证

**测试脚本**：`scripts/test-integration.sh`
```bash
# 1. 验证 OMC 配置
# 2. 验证 claude-mem 可用性
# 3. 验证 ECC rules 和 skills
# 4. 验证 hooks 配置
# 5. 生成测试报告
```

### 阶段四：文档完善

**需要创建**：
1. `README.md` - 项目介绍和快速开始
2. `INSTALL.md` - 详细安装指南
3. `TROUBLESHOOTING.md` - 常见问题解决

## 理想的用户体验

```bash
# 用户只需执行：
git clone https://github.com/caohui-net/claude-code-env.git
cd claude-code-env
./install.sh

# 脚本自动完成：
# ✓ 检查环境
# ✓ 安装依赖
# ✓ 配置系统
# ✓ 运行测试
# ✓ 显示结果
```

## 待办事项

- [ ] 阶段一：收集配置文件
- [ ] 阶段二：开发安装脚本
- [ ] 阶段三：创建测试脚本
- [ ] 阶段四：完善文档
- [ ] 最终验证：全新环境测试

## 预计时间

- 配置收集：1 小时
- 脚本开发：3-4 小时
- 测试验证：2 小时
- 文档编写：2 小时

**总计**：8-9 小时

## 注意事项

1. **敏感信息处理**
   - API keys 不能提交到仓库
   - 使用环境变量或配置模板

2. **跨平台兼容**
   - 脚本需支持 Linux 和 macOS
   - 考虑 WSL 环境

3. **版本依赖**
   - 明确 Claude Code 最低版本要求
   - 明确 Node.js 版本要求

4. **回滚机制**
   - 安装前备份现有配置
   - 提供卸载脚本

---

**状态**：计划阶段
**下一步**：环境验证通过后开始实施
