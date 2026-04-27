#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PRIVATE_DIR="$(cd "$REPO_DIR/../cadence-private" 2>/dev/null && pwd)" || true
CLAUDE_HOME="$HOME/.claude"

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

# --- helpers ---

link() {
  local target="$1" link_path="$2"
  local label="${link_path#$HOME/}"

  if [[ -L "$link_path" ]]; then
    local current
    current="$(readlink "$link_path")"
    if [[ "$current" == "$target" ]]; then
      echo "  ok  $label (already linked)"
      return
    fi
    echo "  fix $label (repointing symlink)"
    ln -sfn "$target" "$link_path"
    return
  fi

  if [[ -e "$link_path" ]]; then
    if $FORCE; then
      echo "  bak $label → ${link_path}.bak"
      mv "$link_path" "${link_path}.bak"
    else
      echo "  SKIP $label (real file exists; use --force to replace)"
      return
    fi
  fi

  ln -s "$target" "$link_path"
  echo "  new $label → $target"
}

# --- prerequisites ---

if [[ ! -d "$CLAUDE_HOME" ]]; then
  echo "Error: $CLAUDE_HOME does not exist" >&2
  exit 1
fi

if [[ -z "${PRIVATE_DIR:-}" || ! -f "$PRIVATE_DIR/config/CLAUDE.md" ]]; then
  echo "Error: cadence-private repo not found at $REPO_DIR/../cadence-private" >&2
  echo "       Expected sibling directory with config/CLAUDE.md" >&2
  echo "       Create one from templates/user-claude.md in this repo" >&2
  exit 1
fi

# --- user-level CLAUDE.md (from cadence-private) ---

echo "Config:"
link "$PRIVATE_DIR/config/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"

# --- cadence skills ---

echo "Skills:"
mkdir -p "$CLAUDE_HOME/skills"
link "$REPO_DIR/skills/session-start" "$CLAUDE_HOME/skills/session-start"
link "$REPO_DIR/skills/handover" "$CLAUDE_HOME/skills/handover"
link "$REPO_DIR/skills/wrap-up" "$CLAUDE_HOME/skills/wrap-up"
link "$REPO_DIR/skills/next-prompt" "$CLAUDE_HOME/skills/next-prompt"
link "$REPO_DIR/skills/pre-commit" "$CLAUDE_HOME/skills/pre-commit"

echo ""
echo "Done."
