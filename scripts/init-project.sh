#!/usr/bin/env bash
# New projects only. For existing projects with memory at ~/.claude/projects/,
# use the migration path (see cadence roadmap step 5).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CADENCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES="$CADENCE_DIR/templates"
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
CLAUDE_HOME="$HOME/.claude"

PUBLIC=false
[[ "${1:-}" == "--public" ]] && PUBLIC=true

# --- path hash ---

path_hash=$(echo "$PROJECT_DIR" | tr '/' '-')

# --- guard ---

if [[ -f "$PROJECT_DIR/CLAUDE.md" ]]; then
  echo "Error: CLAUDE.md already exists in $PROJECT_DIR" >&2
  echo "       This script is for new projects only" >&2
  exit 1
fi

# --- CLAUDE.md ---

sed "s/<project-name>/$PROJECT_NAME/g" "$TEMPLATES/project-claude.md" > "$PROJECT_DIR/CLAUDE.md"
echo "  new CLAUDE.md"

# --- .claude/memory/ ---

mkdir -p "$PROJECT_DIR/.claude/memory/archive"

sed "s/<project-name>/$PROJECT_NAME/g" "$TEMPLATES/memory.md" > "$PROJECT_DIR/.claude/memory/MEMORY.md"
echo "  new .claude/memory/MEMORY.md"

cp "$TEMPLATES/user_profile.md" "$PROJECT_DIR/.claude/memory/user_profile.md"
echo "  new .claude/memory/user_profile.md"

# --- symlink ---

symlink_dir="$CLAUDE_HOME/projects/$path_hash"
mkdir -p "$symlink_dir"

if [[ -L "$symlink_dir/memory" ]]; then
  echo "  ok  symlink (already exists)"
elif [[ -d "$symlink_dir/memory" ]]; then
  echo "  SKIP symlink ($symlink_dir/memory is a real directory)"
  echo "       Move its contents to .claude/memory/ and replace with a symlink manually"
else
  ln -s "$PROJECT_DIR/.claude/memory" "$symlink_dir/memory"
  echo "  new symlink: $symlink_dir/memory → .claude/memory/"
fi

# --- .gitignore ---

if [[ ! -f "$PROJECT_DIR/.gitignore" ]]; then
  touch "$PROJECT_DIR/.gitignore"
fi

entries=".claude/settings.local.json"
if $PUBLIC; then
  entries="$entries
.claude/memory/"
fi

for entry in $entries; do
  if ! grep -qF "$entry" "$PROJECT_DIR/.gitignore"; then
    echo "$entry" >> "$PROJECT_DIR/.gitignore"
    echo "  add .gitignore: $entry"
  fi
done

echo ""
echo "Done. Next steps:"
echo "  1. Fill in CLAUDE.md placeholders"
echo "  2. Fill in .claude/memory/user_profile.md placeholders"
if $PUBLIC; then
  echo "  3. Memory is gitignored (public repo) — back up via cadence-private"
else
  echo "  3. Memory is committed (private repo) — version-controlled with the project"
fi
