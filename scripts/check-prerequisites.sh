#!/bin/bash
# check-prerequisites.sh - 检查Claude Code优化环境的前置条件
# 用法: bash scripts/check-prerequisites.sh [--strict]

set -uo pipefail

STRICT_MODE=false
if [[ "${1:-}" == "--strict" ]]; then
    STRICT_MODE=true
fi

REQUIRED_FAIL=0
OPTIONAL_WARN=0

# 颜色输出
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "=== Claude Code 优化环境前置条件检查 ==="
echo ""

# 检查函数
check_command() {
    local cmd=$1
    local name=$2
    local install_hint=$3
    local required=${4:-true}

    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name: $(command -v "$cmd")"
        return 0
    else
        if [ "$required" = true ]; then
            echo -e "${RED}✗${NC} $name: 未安装"
            echo "  安装: $install_hint"
            ((REQUIRED_FAIL++))
        else
            echo -e "${YELLOW}⚠${NC} $name: 未安装 (可选)"
            echo "  安装: $install_hint"
            ((OPTIONAL_WARN++))
        fi
        return 1
    fi
}

check_plugin() {
    local plugin_name=$1
    local check_cmd=$2
    local install_hint=$3

    if eval "$check_cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $plugin_name: 已安装"
        return 0
    else
        echo -e "${RED}✗${NC} $plugin_name: 未安装"
        echo "  安装: $install_hint"
        ((REQUIRED_FAIL++))
        return 1
    fi
}

echo "## 必需插件"
check_plugin "OMC (oh-my-claudecode)" \
    "claude plugins list 2>/dev/null | grep -q oh-my-claudecode" \
    "claude plugins install oh-my-claudecode@omc"

check_plugin "claude-mem" \
    "command -v claude-mem" \
    "npm install -g claude-mem@10.6.2 (然后参考 docs/install-log.md 完成配置)"

check_plugin "Lightpanda" \
    "claude plugins list 2>/dev/null | grep -q lightpanda" \
    "claude plugins install lightpanda"

check_plugin "RTK (Rust Token Killer)" \
    "command -v rtk" \
    "参考 docs/rtk-integration.md"

echo ""
echo "## 必需命令"
check_command "claude" "Claude Code CLI" "从 https://claude.ai/code 下载安装"
check_command "jq" "jq (JSON processor)" "apt install jq / brew install jq"
check_command "node" "Node.js" "从 https://nodejs.org 下载安装" false

echo ""
echo "=== 检查结果 ==="
if [ $REQUIRED_FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ 所有必需组件已安装${NC}"
    if [ $OPTIONAL_WARN -gt 0 ]; then
        echo -e "${YELLOW}⚠ $OPTIONAL_WARN 个可选组件未安装${NC}"
    fi
    echo ""
    echo "下一步: bash install.sh"
    exit 0
else
    echo -e "${RED}✗ $REQUIRED_FAIL 个必需组件缺失${NC}"
    if [ $OPTIONAL_WARN -gt 0 ]; then
        echo -e "${YELLOW}⚠ $OPTIONAL_WARN 个可选组件未安装${NC}"
    fi
    echo ""
    echo "请先安装缺失的组件，然后重新运行此脚本。"

    if [ "$STRICT_MODE" = true ]; then
        exit 1
    else
        exit 0
    fi
fi
