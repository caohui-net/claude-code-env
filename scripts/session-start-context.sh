#!/bin/bash
# Session Start Context - 自动恢复项目上下文
# 不依赖外部脚本，仓库自包含

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_STATE="$PROJECT_ROOT/project-state.json"

if [ ! -f "$PROJECT_STATE" ]; then
  echo "⚠️  project-state.json 不存在"
  exit 0
fi

# 提取关键信息
PROJECT_NAME=$(jq -r '.project.name // "unknown"' "$PROJECT_STATE")
PROJECT_STATUS=$(jq -r '.project.status // "unknown"' "$PROJECT_STATE")
CURRENT_FOCUS=$(jq -r '.current_focus // "无"' "$PROJECT_STATE")
SUMMARY_FILE=$(jq -r '.project.summary_file // "docs/PROJECT-SUMMARY.md"' "$PROJECT_STATE")

# 输出项目摘要
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           🔍 检测到项目上下文                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "  项目名称：$PROJECT_NAME"
echo "  项目状态：$PROJECT_STATUS"
echo "  当前焦点：$CURRENT_FOCUS"
echo ""
echo "  📄 完整文档：$SUMMARY_FILE"
echo ""

# 检查需要读取的文件
READ_FIRST=$(jq -r '.recovery.read_first[]? // empty' "$PROJECT_STATE")
if [ -n "$READ_FIRST" ]; then
  echo "  ⚠️  建议立即读取以下文件恢复上下文："
  echo "$READ_FIRST" | while read -r file; do
    if [ -f "$PROJECT_ROOT/$file" ]; then
      echo "     - $file ✓"
    else
      echo "     - $file ✗ (不存在)"
    fi
  done
  echo ""
fi

# 检查 next_actions
NEXT_ACTIONS=$(jq -r '.next_actions[]? // empty' "$PROJECT_STATE" | head -3)
if [ -n "$NEXT_ACTIONS" ]; then
  echo "  📋 下一步行动："
  echo "$NEXT_ACTIONS" | while read -r action; do
    echo "     • $action"
  done
  echo ""
fi

echo "╚════════════════════════════════════════════════════════════╝"
echo ""
