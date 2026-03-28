# Git Worktrees 最佳实践

## 概述

Git worktrees 允许在同一仓库中同时检出多个分支到不同目录，实现真正的并行开发。

## 为什么使用 Worktrees

**传统方式的问题**：
```bash
# 需要频繁切换分支
git checkout feature-a  # 工作被打断
# 修改文件...
git checkout main       # 又要切换回来
```

**Worktrees 的优势**：
```bash
# 每个功能独立目录
project/
├── main/           # 主分支
├── feature-a/      # 功能 A
└── feature-b/      # 功能 B
```

## 基本用法

### 1. 创建 Worktree
```bash
# 基于当前分支创建新 worktree
git worktree add ../project-feature-a -b feature-a

# 基于指定分支创建
git worktree add ../project-hotfix -b hotfix/bug-123 main
```

### 2. 列出所有 Worktrees
```bash
git worktree list
# /path/to/project              abc123 [main]
# /path/to/project-feature-a    def456 [feature-a]
```

### 3. 删除 Worktree
```bash
# 先删除目录
rm -rf ../project-feature-a

# 清理 git 记录
git worktree prune
```

## 推荐工作流

### 场景 1：新功能开发

```bash
# 1. 创建功能分支的 worktree
git worktree add ../myproject-auth -b feature/auth

# 2. 进入新目录工作
cd ../myproject-auth

# 3. 开发、测试、提交
# ... 正常开发流程 ...

# 4. 完成后合并
cd ../myproject  # 回到主仓库
git merge feature/auth

# 5. 清理 worktree
rm -rf ../myproject-auth
git worktree prune
git branch -d feature/auth
```

### 场景 2：紧急修复

```bash
# 主分支有紧急 bug，但当前分支工作未完成
# 不需要 stash，直接创建 worktree
git worktree add ../myproject-hotfix -b hotfix/critical-bug main

cd ../myproject-hotfix
# 修复 bug
# 提交并推送
# 删除 worktree
```

### 场景 3：并行开发多个功能

```bash
# 同时开发 3 个功能
git worktree add ../myproject-feature-a -b feature/a
git worktree add ../myproject-feature-b -b feature/b
git worktree add ../myproject-feature-c -b feature/c

# 在不同终端窗口中同时工作
# 每个功能独立测试、提交
```

## 注意事项

### ✅ 推荐做法

1. **命名规范**
   ```bash
   # 使用项目名前缀
   git worktree add ../myproject-feature-name -b feature/name
   ```

2. **定期清理**
   ```bash
   # 查看所有 worktrees
   git worktree list

   # 删除不用的
   git worktree remove path/to/worktree
   ```

3. **测试隔离**
   - 每个 worktree 有独立的 node_modules
   - 避免依赖冲突

### ❌ 避免的做法

1. **不要在 worktree 中创建 worktree**
2. **不要删除主仓库的 .git 目录**
3. **不要在多个 worktrees 中检出同一分支**

## 与 Claude Code 集成

### 创建 Worktree Skill

可以创建一个简单的 skill 来自动化 worktree 工作流：

```bash
# ~/.claude/skills/git-worktrees/SKILL.md
```

内容参考本文档的工作流。

### 使用场景

- 需要同时开发多个功能
- 需要快速切换到紧急修复
- 需要对比不同分支的代码

## 参考资料

- Git 官方文档：https://git-scm.com/docs/git-worktree
- 来源：借鉴 Superpowers 的 using-git-worktrees skill

---

**状态**：最佳实践文档
**集成方式**：独立使用，不依赖 Superpowers
