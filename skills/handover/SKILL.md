---
name: handover
description: End a session with work-in-progress. Verifies clean state, updates memory and docs, captures agreed-but-unstarted scope, produces big-picture comments, and generates an opening prompt for the next fresh session. Universal — works with any project that has a CLAUDE.md and memory setup. User-invoked.
---

# /handover

Run this at the end of a session when work will continue in a fresh session on this project. Goal: zero information loss across the session boundary. Docs and memory carry durable facts; the opening prompt carries ephemeral context.

For partial use: `/wrap-up` runs steps 1–6 only (no opening prompt — use when the next work is on a different project). `/next-prompt` runs step 7 only (use when the session is already wrapped up but you need a prompt).

Execute the full protocol and present the results. User can skip or modify any step.

## 1. Verify clean state

Run gates before anything else. The next session must start from a known-good state.

**Discover commands:** read the project's CLAUDE.md "Commands" section to find the test and lint commands. If no commands section exists or no test/lint commands are listed, ask the user what to run.

**Run in sequence:**

1. Test command(s) from CLAUDE.md
2. Lint command(s) from CLAUDE.md (if any)
3. `git status`
4. `git log --oneline -5`

- If uncommitted changes exist: **ask** the user whether to commit, stash, or leave them. Capture the outcome in the opening prompt. Never commit without explicit permission.
- If tests or lint fail: fix before handing over.

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

## 7. Generate opening prompt

A copy-pasteable block the user gives the next fresh session. Structure:

1. **Orientation ask** — _"Summarize the project from CLAUDE.md + docs + memory."_ Forces the new session to read durable artifacts before acting.
2. **Git state snapshot** — branch, sync status, latest commit (hash + subject). Saves the next session a tool call.
3. **This session's task** — the agreed next-session scope, concrete enough that the new session can plan without re-deriving. Include file estimates, design constraints, anything surfaced in prior discussion.
4. **Execution ask** — _"Draft a formal plan"_ or _"Execute phase X"_, depending on whether the plan is already approved.

The prompt must be self-contained. A new Claude reading only this prompt + auto-loaded CLAUDE.md + memory should have everything needed to start working. No implicit references to "what we discussed earlier".

## When to run

- User says "let's start a new session", "time to hand over", or similar
- Claude flags a natural handover seam (commit boundary, sub-task complete, topic shift) and user approves
- User's discretion at any time

## Anti-patterns

- **Don't dump raw conversation history into the opening prompt.** It's a curated summary, not a transcript.
- **Don't commit without explicit permission.** Always ask first.
- **Don't assume the next session remembers anything.** Every piece of context must be in docs, memory, or the opening prompt.
- **Don't skip verify.** A broken build discovered by the next session wastes its first 10 minutes diagnosing something this protocol should have caught.
