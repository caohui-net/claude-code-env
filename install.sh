#!/bin/bash
# Claude Code 环境安装脚本 v2.0

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

HOOKS_PROFILE="none"
DRY_RUN=false
YES=false
BACKUP_ONLY=false
RESTORE_ID=""

show_help() {
  cat << HELP
Claude Code 环境安装脚本

用法: $0 [选项]

选项:
  --hooks PROFILE       安装 hooks 配置 (none|minimal|omc)
  --dry-run            预览操作，不实际修改文件
  --yes                跳过确认提示
  --backup-only        只备份，不安装
  --restore ID         从备份恢复
  --verify             验证当前安装
  -h, --help           显示此帮助信息

HELP
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --hooks)
      HOOKS_PROFILE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --yes)
      YES=true
      shift
      ;;
    --backup-only)
      BACKUP_ONLY=true
      shift
      ;;
    --restore)
      RESTORE_ID="$2"
      shift 2
      ;;
    --verify)
      ./scripts/verify-installation.sh
      exit 0
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "未知选项: $1"
      show_help
      exit 1
      ;;
  esac
done

if [[ ! "$HOOKS_PROFILE" =~ ^(none|minimal|omc)$ ]]; then
  echo -e "${RED}错误: 无效的 hooks profile: $HOOKS_PROFILE${NC}"
  exit 1
fi

CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backups"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

create_backup() {
  local backup_id=$(date +%Y%m%d-%H%M%S)
  local backup_path="$BACKUP_DIR/$backup_id"
  
  echo -e "${GREEN}创建备份: $backup_id${NC}"
  
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] 将创建备份到: $backup_path"
    echo "$backup_id"
    return 0
  fi
  
  mkdir -p "$backup_path"
  [ -f "$SETTINGS_FILE" ] && cp "$SETTINGS_FILE" "$backup_path/settings.json"
  [ -f "$CLAUDE_DIR/CLAUDE.md" ] && cp "$CLAUDE_DIR/CLAUDE.md" "$backup_path/CLAUDE.md"
  [ -d "$CLAUDE_DIR/rules" ] && cp -r "$CLAUDE_DIR/rules" "$backup_path/"
  [ -d "$CLAUDE_DIR/skills" ] && cp -r "$CLAUDE_DIR/skills" "$backup_path/"
  
  echo -e "${GREEN}✅ 备份完成${NC}"
  echo "$backup_id"
}

restore_backup() {
  local backup_id="$1"
  local backup_path="$BACKUP_DIR/$backup_id"
  
  if [ ! -d "$backup_path" ]; then
    echo -e "${RED}错误: 备份不存在: $backup_id${NC}"
    exit 1
  fi
  
  echo -e "${YELLOW}恢复备份: $backup_id${NC}"
  
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] 将从 $backup_path 恢复"
    return 0
  fi
  
  [ -f "$backup_path/settings.json" ] && cp "$backup_path/settings.json" "$SETTINGS_FILE"
  [ -f "$backup_path/CLAUDE.md" ] && cp "$backup_path/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
  [ -d "$backup_path/rules" ] && cp -r "$backup_path/rules" "$CLAUDE_DIR/"
  [ -d "$backup_path/skills" ] && cp -r "$backup_path/skills" "$CLAUDE_DIR/"
  
  echo -e "${GREEN}✅ 恢复完成${NC}"
}

install_hooks() {
  local profile="$1"
  local hooks_file="hooks/hooks.$profile.json"
  
  if [ ! -f "$hooks_file" ]; then
    echo -e "${RED}错误: hooks 文件不存在: $hooks_file${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}安装 hooks: $profile${NC}"
  
  if [ ! -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}settings.json 不存在，创建默认配置${NC}"
    if [ "$DRY_RUN" = false ]; then
      mkdir -p "$CLAUDE_DIR"
      echo '{}' > "$SETTINGS_FILE"
    fi
  fi
  
  local new_hooks=$(jq '.hooks' "$hooks_file")
  local current_settings=$(cat "$SETTINGS_FILE")
  
  local cleaned_settings=$(echo "$current_settings" | jq '
    .hooks = (.hooks // {} | 
      to_entries | 
      map({
        key: .key,
        value: (.value | map(select(.description // "" | test("\\[claude-code-env:") | not)))
      }) | 
      from_entries
    )
  ')
  
  local merged_settings=$(echo "$cleaned_settings" | jq --argjson new "$new_hooks" '
    .hooks = (.hooks // {} | 
      to_entries + ($new | to_entries) | 
      group_by(.key) | 
      map({
        key: .[0].key,
        value: (map(.value) | add)
      }) | 
      from_entries
    )
  ')
  
  echo -e "${YELLOW}变更预览:${NC}"
  diff <(echo "$current_settings" | jq -S '.hooks') <(echo "$merged_settings" | jq -S '.hooks') || true
  
  if [ "$YES" = false ] && [ "$DRY_RUN" = false ]; then
    read -p "应用这些变更? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "已取消"
      exit 0
    fi
  fi
  
  if [ "$DRY_RUN" = false ]; then
    echo "$merged_settings" > "$SETTINGS_FILE"
    echo -e "${GREEN}✅ hooks 已安装${NC}"
  else
    echo "[DRY-RUN] 将写入 $SETTINGS_FILE"
  fi
}

copy_rules_skills() {
  echo -e "${GREEN}复制 rules 和 skills${NC}"
  
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] 将复制 rules/ 到 $CLAUDE_DIR/rules/"
    echo "[DRY-RUN] 将复制 skills/ 到 $CLAUDE_DIR/skills/"
    return 0
  fi
  
  mkdir -p "$CLAUDE_DIR"
  cp -r rules "$CLAUDE_DIR/"
  cp -r skills "$CLAUDE_DIR/"
  
  echo -e "${GREEN}✅ 复制完成${NC}"
}

main() {
  echo "=== Claude Code 环境安装 ==="
  echo
  
  if [ -n "$RESTORE_ID" ]; then
    restore_backup "$RESTORE_ID"
    exit 0
  fi
  
  local backup_id=$(create_backup)
  
  if [ "$BACKUP_ONLY" = true ]; then
    echo -e "${GREEN}备份完成，退出${NC}"
    exit 0
  fi
  
  copy_rules_skills
  
  if [ "$HOOKS_PROFILE" != "none" ]; then
    install_hooks "$HOOKS_PROFILE"
  else
    echo -e "${YELLOW}跳过 hooks 安装 (--hooks none)${NC}"
  fi
  
  echo
  echo -e "${GREEN}=== 安装完成 ===${NC}"
  echo
  echo "备份 ID: $backup_id"
  echo "恢复命令: $0 --restore $backup_id"
  echo
  echo "验证安装: $0 --verify"
}

main
