---
name: wrap-up
description: Close a session cleanly without generating an opening prompt. Verifies clean state, updates memory and docs, captures agreed-but-unstarted scope, produces big-picture comments. Use /handover if you also want an opening prompt for the next session. Universal — works with any project that has a CLAUDE.md and memory setup. User-invoked.
---

# /wrap-up

Run this at the end of a session when you want to close cleanly but don't need an opening prompt for the next session. For the full handover (wrap-up + opening prompt), use `/handover` instead.

Execute the full protocol and present the results. User can skip or modify any step.

## 1. Verify clean state

Run gates before anything else. The next session must start from a known-good state.

**Discover commands:** read the project's CLAUDE.md "Commands" section to find the test and lint commands. If no commands section exists or no test/lint commands are listed, ask the user what to run.

**Run in sequence:**

1. Test command(s) from CLAUDE.md
2. Lint command(s) from CLAUDE.md (if any)
3. `git status`
4. `git log --oneline -5`

- If uncommitted changes exist: **ask** the user whether to commit, stash, or leave them. Never commit without explicit permission.
- If tests or lint fail: fix before wrapping up.

## 2. Update memory files

Check each memory entry for staleness:

- **`user_profile.md`** — update only if the session revealed a new role, preference, or working-style shift
- **`feedback_*.md`** — add new entries for any corrections or validated choices from this session
- **`project_<feature>.md`** — update the active feature's current state + next steps. This drifts every session; most important update
- **`reference_*.md`** — update if external pointers, integration status, or cross-repo relationships changed
- **`MEMORY.md` index** — sync one-line descriptions with actual file contents

## 3. Update project docs if needed

- **`CLAUDE.md`** — verify rules, conventions, architecture still reflect reality
- **`docs/`** — if a new pattern emerged this session, add a doc and update the docs index

If everything was captured in-commit, this step is usually a no-op. The check is for anything discussed-but-not-landed.

## 4. Capture agreed-but-unstarted scope

If user and Claude agreed on the next session's shape but haven't started executing, write it into `project_<feature>.md` under a "Next steps" heading. This is the most commonly lost information — conversation agreements that don't survive into any durable artifact.

## 5. Big-picture comments for the user

Write a short section covering:

- **Going well** — patterns worth preserving
- **Watch** — tech debt, rough edges, concerns the next session might hit
- **Design observations** — anything the next session's planning should consider

The user decides what to pass forward. Not everything here needs to reach the next Claude — some is for the user's own judgment.

## 6. Lessons sweep

Scan the session for non-obvious discoveries that would change how a future session approaches similar work. Only surface candidates that clear this bar — skip silently if nothing qualifies.

Propose max 1–2 candidates. For each, state the lesson type (avoidance, efficiency, mental model, constraint, validated pattern) and one-line content. User approves before save.

See `docs/methodology.md` "Lesson capture" for the filter criteria and what does not qualify.

## When to run

- Session is ending but the next work is on a different project (no opening prompt needed)
- Work is complete — session closes cleanly, no continuation planned
- User's discretion at any time

## Anti-patterns

- **Don't commit without explicit permission.** Always ask first.
- **Don't assume the next session remembers anything.** Every piece of context must be in docs or memory.
- **Don't skip verify.** A broken build discovered by the next session wastes its first 10 minutes diagnosing something this protocol should have caught.
