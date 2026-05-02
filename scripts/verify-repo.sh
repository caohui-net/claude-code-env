#!/bin/bash
# 仓库验证脚本

set -e

ERRORS=0
WARNINGS=0

error() {
  echo "❌ $1"
  ((ERRORS++))
}

warn() {
  echo "⚠️  $1"
  ((WARNINGS++))
}

info() {
  echo "ℹ️  $1"
}

success() {
  echo "✅ $1"
}

echo "=== 仓库验证 ==="
echo

# 1. JSON 语法检查
echo "1. 检查 JSON 语法..."
for file in $(find . -name "*.json" -not -path "./.git/*" -not -path "./node_modules/*"); do
  if jq empty "$file" 2>/dev/null; then
    success "$file"
  else
    error "$file - JSON 语法错误"
  fi
done
echo

# 2. Shell 脚本语法检查
echo "2. 检查 Shell 脚本语法..."
for file in $(find . -name "*.sh" -not -path "./.git/*"); do
  if bash -n "$file" 2>/dev/null; then
    success "$file"
  else
    error "$file - Shell 语法错误"
  fi
done
echo

# 3. JavaScript 语法检查
echo "3. 检查 JavaScript 语法..."
if command -v node >/dev/null; then
  for file in $(find scripts -name "*.js" 2>/dev/null); do
    if node --check "$file" 2>/dev/null; then
      success "$file"
    else
      error "$file - JavaScript 语法错误"
    fi
  done
else
  warn "Node.js 未安装，跳过 JS 语法检查"
fi
echo

# 4. hooks 配置验证
echo "4. 检查 hooks 配置..."
if [ -f "scripts/verify-hooks.sh" ]; then
  if bash scripts/verify-hooks.sh; then
    success "hooks 配置验证通过"
  else
    error "hooks 配置验证失败"
  fi
else
  warn "scripts/verify-hooks.sh 不存在"
fi
echo

# 5. .omc 运行时文件检查
echo "5. 检查 .omc 运行时文件..."
if git ls-files .omc/state/ 2>/dev/null | grep -q .; then
  error ".omc/state/ 包含已跟踪的运行时文件"
  git ls-files .omc/state/
else
  success ".omc/state/ 未跟踪运行时文件"
fi
echo

# 6. 配置一致性检查
echo "6. 检查配置一致性..."
if [ -f "project-state.json" ] && [ -f ".project-context.json" ]; then
  # 检查项目名称
  ps_name=$(jq -r '.project.name' project-state.json)
  pc_name=$(jq -r '.project' .project-context.json)
  if [ "$ps_name" = "$pc_name" ]; then
    success "项目名称一致"
  else
    error "项目名称不一致: $ps_name vs $pc_name"
  fi

  # 检查更新时间
  ps_updated=$(jq -r '.last_updated' project-state.json)
  pc_updated=$(jq -r '.last_updated' .project-context.json)
  if [ "$ps_updated" = "$pc_updated" ]; then
    success "更新时间一致"
  else
    warn "更新时间不一致: $ps_updated vs $pc_updated"
  fi
else
  warn "project-state.json 或 .project-context.json 不存在"
fi
echo

# 7. 安装脚本检查
echo "7. 检查安装脚本..."
if [ -f "install.sh" ]; then
  if bash -n install.sh 2>/dev/null; then
    success "install.sh 语法正确"
  else
    error "install.sh 语法错误"
  fi

  # 检查 --dry-run 支持
  if grep -q "DRY_RUN" install.sh; then
    success "install.sh 支持 --dry-run"
  else
    warn "install.sh 不支持 --dry-run"
  fi
else
  error "install.sh 不存在"
fi
echo

# 总结
echo "=== 验证完成 ==="
echo "错误: $ERRORS"
echo "警告: $WARNINGS"
echo

if [ $ERRORS -gt 0 ]; then
  exit 1
else
  exit 0
fi
