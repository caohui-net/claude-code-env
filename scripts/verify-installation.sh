#!/bin/bash
# 安装验证脚本

FAILS=0
WARNS=0
INFOS=0

fail() {
  echo "❌ FAIL: $1"
  ((FAILS++))
}

warn() {
  echo "⚠️  WARN: $1"
  ((WARNS++))
}

info() {
  echo "ℹ️  INFO: $1"
  ((INFOS++))
}

success() {
  echo "✅ $1"
}

echo "=== 安装验证 ==="
echo

# 1. 配置文件检查
echo "1. 检查配置文件..."
SETTINGS="$HOME/.claude/settings.json"
if [ -f "$SETTINGS" ]; then
  if jq empty "$SETTINGS" 2>/dev/null; then
    success "settings.json 存在且有效"
  else
    fail "settings.json 无效"
  fi
else
  fail "settings.json 不存在"
fi
echo

# 2. hooks 检查
echo "2. 检查 hooks..."
if [ -f "$SETTINGS" ]; then
  hook_count=$(jq '.hooks | length' "$SETTINGS" 2>/dev/null || echo 0)
  info "已配置 $hook_count 个 hook 类型"

  # 检查 claude-code-env hooks
  cce_hooks=$(jq -r '.hooks | to_entries[] | .value[] | select(.description | test("\\[claude-code-env:")) | .description' "$SETTINGS" 2>/dev/null | wc -l)
  if [ "$cce_hooks" -gt 0 ]; then
    info "已安装 $cce_hooks 个 claude-code-env hooks"
  fi
fi
echo

# 3. MCP 服务器检查
echo "3. 检查 MCP 服务器..."
if [ -f ".mcp.json" ]; then
  mcp_count=$(jq '.mcpServers | length' .mcp.json 2>/dev/null || echo 0)
  info "项目级 MCP: $mcp_count 个服务器"
fi

if [ -f "$SETTINGS" ]; then
  mcp_count=$(jq '.mcpServers | length' "$SETTINGS" 2>/dev/null || echo 0)
  info "全局 MCP: $mcp_count 个服务器"
fi
echo

# 4. 依赖工具检查
echo "4. 检查依赖工具..."
command -v omc >/dev/null && success "OMC 已安装" || warn "OMC 未安装"
command -v claude-mem >/dev/null && success "claude-mem 已安装" || warn "claude-mem 未安装"
command -v rtk >/dev/null && success "RTK 已安装" || warn "RTK 未安装"
command -v node >/dev/null && success "Node.js 已安装" || warn "Node.js 未安装"
command -v jq >/dev/null && success "jq 已安装" || warn "jq 未安装"
echo

# 5. 端口检查
echo "5. 检查端口..."
if command -v nc >/dev/null; then
  nc -z 127.0.0.1 37777 2>/dev/null && info "claude-mem 运行中 (37777)" || warn "claude-mem 未运行 (37777)"
  nc -z 127.0.0.1 38888 2>/dev/null && info "claude-mem-proxy 运行中 (38888)" || warn "claude-mem-proxy 未运行 (38888)"
else
  warn "nc 未安装，跳过端口检查"
fi
echo

# 6. Claude Code 版本
echo "6. 检查 Claude Code..."
if command -v claude >/dev/null; then
  version=$(claude --version 2>/dev/null || echo "unknown")
  info "Claude Code 版本: $version"
else
  warn "Claude Code CLI 未安装"
fi
echo

# 总结
echo "=== 验证完成 ==="
echo "失败: $FAILS"
echo "警告: $WARNS"
echo "信息: $INFOS"
echo

if [ $FAILS -gt 0 ]; then
  exit 1
else
  exit 0
fi
