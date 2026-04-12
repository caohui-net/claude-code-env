#!/bin/bash
# Claude Code Environment Setup Script
# Run this on a fresh machine to set up your Claude Code environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "=== Claude Code Environment Setup ==="
echo ""

# 1. Install settings.json
echo "[1/4] Installing settings.json..."
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    echo "  Existing settings.json found. Merging hooks field..."
    # Preserve existing settings, just merge hooks from template
    # User must manually set ANTHROPIC_AUTH_TOKEN
    echo "  NOTE: Edit $CLAUDE_DIR/settings.json and set your ANTHROPIC_AUTH_TOKEN"
else
    echo "  Creating new settings.json from template..."
    mkdir -p "$CLAUDE_DIR"
    cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    echo "  IMPORTANT: Edit $CLAUDE_DIR/settings.json and replace:"
    echo "    - YOUR_AUTH_TOKEN with your actual Anthropic auth token"
    echo "    - YOUR_BASE_URL_OR_REMOVE with your base URL or remove that field"
fi
echo "  Done."
echo ""

# 2. Install rules
echo "[2/6] Installing rules..."
mkdir -p "$CLAUDE_DIR/rules/common"
cp "$SCRIPT_DIR/rules/common/"*.md "$CLAUDE_DIR/rules/common/"
echo "  Installed $(ls "$SCRIPT_DIR/rules/common/" | wc -l) common rule files"

# Install language-specific rules
for lang in typescript python golang; do
    if [ -d "$SCRIPT_DIR/rules/$lang" ]; then
        mkdir -p "$CLAUDE_DIR/rules/$lang"
        cp "$SCRIPT_DIR/rules/$lang/"*.md "$CLAUDE_DIR/rules/$lang/"
        echo "  Installed $(ls "$SCRIPT_DIR/rules/$lang/" | wc -l) $lang rule files"
    fi
done
echo ""

# 3. Install skills
echo "[3/6] Installing skills..."
if [ -d "$SCRIPT_DIR/skills" ]; then
    mkdir -p "$CLAUDE_DIR/skills"
    cp -r "$SCRIPT_DIR/skills/"* "$CLAUDE_DIR/skills/"
    echo "  Installed $(ls "$SCRIPT_DIR/skills/" | wc -l) skills"
else
    echo "  No skills directory found. Skipping."
fi
echo ""

# 4. Install hooks config (reference only)
echo "[4/6] Hooks configuration..."
echo "  Hooks template is at: $SCRIPT_DIR/hooks/hooks.json"
echo "  Review it and merge desired hooks into $CLAUDE_DIR/settings.json manually."
echo "  Or run: cat $SCRIPT_DIR/hooks/hooks.json"
echo ""

# 5. Install global CLAUDE.md (optional)
echo "[5/6] Global CLAUDE.md (optional)..."
if [ -f "$HOME/CLAUDE.md" ]; then
    echo "  ~/CLAUDE.md already exists. Skipping."
    echo "  Reference template at: $SCRIPT_DIR/CLAUDE.md"
else
    read -p "  Install global CLAUDE.md to ~/CLAUDE.md? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$SCRIPT_DIR/CLAUDE.md" "$HOME/CLAUDE.md"
        echo "  Installed ~/CLAUDE.md"
    else
        echo "  Skipped. Template at: $SCRIPT_DIR/CLAUDE.md"
    fi
fi
echo ""

# 6. Profiles information
echo "[6/6] Optional token-efficient profiles..."
echo "  Profiles reduce Claude output tokens for different use cases:"
echo "  - coding/CLAUDE.coding.md : Code development (~30% token reduction)"
echo "  - CLAUDE.agents.md        : Automation pipelines (~50% token reduction)"
echo "  - CLAUDE.analysis.md      : Data analysis tasks"
echo "  - token-efficient/        : Maximum cost optimization (~63% token reduction)"
echo ""
echo "  Usage options:"
echo "    Global : cp $SCRIPT_DIR/profiles/CLAUDE.agents.md ~/CLAUDE.md"
echo "    Project: cp $SCRIPT_DIR/profiles/coding/CLAUDE.coding.md ~/projects/my-app/CLAUDE.md"
echo "  See profiles/README.md for full details."
echo ""

echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/settings.json and set your auth token"
echo "  2. Review and merge hooks from hooks/hooks.json if desired"
echo "  3. Check mcp/mcp-servers.json for MCP server configurations"
echo "  4. Install Claude Code: npm install -g @anthropic-ai/claude-code"
echo ""
