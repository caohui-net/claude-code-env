#!/bin/bash
# 从 project-state.json 生成 .project-context.json

set -e

PROJECT_STATE="project-state.json"
OUTPUT=".project-context.json"

if [ ! -f "$PROJECT_STATE" ]; then
  echo "错误：$PROJECT_STATE 不存在"
  exit 1
fi

# 提取关键字段生成简化版本
jq '{
  _generated: true,
  _source: "project-state.json",
  _generated_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
  project: .project.name,
  status: .project.status,
  last_updated: .last_updated,
  completed_phases: [.phases[].id],
  key_files: .key_files
}' "$PROJECT_STATE" > "$OUTPUT"

echo "✅ 已生成 $OUTPUT"
