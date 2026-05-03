#!/bin/bash
command -v jq >/dev/null 2>&1 || { echo "gate-commit.sh: jq required" >&2; exit 1; }

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -qE '\bgit\s+push(\s|$)'; then
  CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
  FLAG="$CWD/.claude/.push-authorized-$PPID"

  if [ -f "$FLAG" ]; then
    rm "$FLAG"
    exit 0
  else
    REASON="Push gate: no authorization flag. Ask the user for explicit permission, then run in a SEPARATE command: touch $CWD/.claude/.push-authorized-$PPID"
    jq -n --arg r "$REASON" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
    exit 0
  fi
fi

exit 0
