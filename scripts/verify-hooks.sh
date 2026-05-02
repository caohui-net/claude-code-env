#!/bin/bash
# 验证 hooks 配置

set -e

HOOKS_DIR="hooks"

echo "=== Hooks 验证 ==="

# 验证 minimal hooks
verify_minimal() {
  local file="$HOOKS_DIR/hooks.minimal.json"
  echo "检查 $file..."

  # JSON 语法
  jq empty "$file" || { echo "❌ JSON 语法错误"; return 1; }

  # 不包含外部脚本引用
  if grep -q '\${CLAUDE_PLUGIN_ROOT}' "$file"; then
    echo "❌ 不应包含 \${CLAUDE_PLUGIN_ROOT}"
    return 1
  fi

  # 允许项目内部脚本（scripts/），但输出提示
  local commands=$(jq -r '.. | .command? // empty' "$file")
  if echo "$commands" | grep -q 'scripts/'; then
    echo "ℹ️  引用项目内部脚本（仓库自包含，允许）"
  fi

  echo "✅ hooks.minimal.json 验证通过"
}

# 验证 omc hooks
verify_omc() {
  local file="$HOOKS_DIR/hooks.omc.json"
  echo "检查 $file..."

  # JSON 语法
  jq empty "$file" || { echo "❌ JSON 语法错误"; return 1; }

  # 检查 _meta.requires
  if ! jq -e '._meta.requires | contains(["oh-my-claudecode"])' "$file" >/dev/null; then
    echo "⚠️  未声明 OMC 依赖"
  fi

  echo "✅ hooks.omc.json 验证通过"
}

# 验证 reference hooks
verify_reference() {
  local file="$HOOKS_DIR/hooks.reference.json"
  echo "检查 $file..."

  # JSON 语法
  jq empty "$file" || { echo "❌ JSON 语法错误"; return 1; }

  # 检查 installable 标记
  if ! jq -e '._meta.installable == false' "$file" >/dev/null; then
    echo "⚠️  应标记为 installable: false"
  fi

  echo "✅ hooks.reference.json 验证通过"
}

verify_minimal
verify_omc
verify_reference

echo "=== 验证完成 ==="
