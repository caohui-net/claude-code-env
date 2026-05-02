# Hooks 配置说明

## 可用配置

### hooks.minimal.json
- **依赖**: 无
- **适用**: 所有用户
- **内容**: 只包含内联脚本，零外部依赖
- **包含的 hooks**:
  - 阻止 dev server 在 tmux 外运行
  - tmux 使用提醒
  - git push 前提醒
  - 阻止创建随机 .md 文件
  - PR 创建后日志

### hooks.omc.json
- **依赖**: oh-my-claudecode 插件
- **适用**: 已安装 OMC 的用户
- **内容**: 依赖 OMC 插件脚本的 hooks
- **包含的 hooks**:
  - 手动压缩建议
  - 压缩前状态保存
  - 会话启动时加载上下文
  - 编辑后自动格式化
  - TypeScript 类型检查
  - console.log 警告
  - 会话结束时持久化状态

### hooks.reference.json
- **依赖**: 多种外部脚本
- **适用**: 仅作参考
- **警告**: 不要直接安装，需要审查依赖
- **说明**: 包含所有 hooks 的完整参考配置

## 安装方法

```bash
# 安装 minimal hooks（推荐新用户）
./install.sh --hooks minimal

# 安装 omc hooks（需要先安装 OMC）
./install.sh --hooks omc

# 不安装 hooks
./install.sh --hooks none
```

## _meta 字段说明

每个配置文件包含 `_meta` 字段，但该字段不会被写入 `~/.claude/settings.json`。
它仅用于文档说明和验证。

```json
{
  "_meta": {
    "name": "配置名称",
    "profile": "配置标识",
    "requires": ["依赖列表"],
    "installable": true/false,
    "description": "配置说明"
  }
}
```

## 标记说明

所有 hooks 的 description 字段都包含 `[claude-code-env:PROFILE]` 标记，用于识别和管理：
- `[claude-code-env:minimal]` - minimal 配置的 hooks
- `[claude-code-env:omc]` - omc 配置的 hooks

安装脚本会根据这些标记自动替换旧的 hooks，保留用户自定义的 hooks。
