#!/bin/bash
# 从 project-state.json 生成 .project-context.json

set -e

PROJECT_STATE="project-state.json"
OUTPUT=".project-context.json"

if [ ! -f "$PROJECT_STATE" ]; then
  echo "错误：$PROJECT_STATE 不存在"
  exit 1
fi

# 提取关键字段生成简化版本（匹配全局脚本期望格式）
jq '{
  _generated: true,
  _source: "project-state.json",
  _generated_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
  name: .project.name,
  type: "claude-code-env",
  status: .project.status,
  phases_completed: ([.phases[].id] | length | tostring),
  last_updated: .last_updated,
  summary_file: .project.summary_file,
  key_files: .key_files
}' "$PROJECT_STATE" > "$OUTPUT"

echo "✅ 已生成 $OUTPUT"
