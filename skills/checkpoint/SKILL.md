---
name: checkpoint
description: Mid-session reflection. Summarizes work so far, checks memory and docs for staleness, surfaces what's out of sync, proposes next steps. Non-destructive — reports findings but doesn't modify files. Universal — works with any project that has a CLAUDE.md and memory setup. User-invoked.
---

# /checkpoint

Mid-session take-stock. Run this at natural pause points — after a chunk of work, before deciding what to do next, or when the session has been going long enough that you want to orient.

This is read-only: it surfaces findings and proposes actions, but doesn't modify files or commit. The user decides what to act on.

## 1. Session summary

Summarize what was accomplished this session so far. Group by commit or logical work unit. Be concise — one line per item, not a narrative.

## 2. State checks

Run these checks and report findings.

### Git state

Run `git status` and `git log --oneline -10`. Report:

- Uncommitted changes (files modified but not staged/committed)
- Commits made this session (identify by recency or context)
- Anything unusual (wrong branch, unexpected state)

### Memory freshness

Read each `project_<feature>.md` that is relevant to this session's work. For each one:

- Does its "Current state" section still reflect reality after this session's changes?
- Does its "Next steps" section need updating (items completed, new items emerged)?
- Should any new memory files be created (new feedback, new feature, new reference)?
- Does `MEMORY.md` index match the actual memory files?

Report what's stale and what specifically needs updating.

### Docs consistency

Check whether this session's work has made any docs stale:

- **CLAUDE.md** — do rules, architecture, skill lists, or the "where knowledge lives" table still reflect reality?
- **`docs/`** — do any docs reference things that changed this session?
- **Templates** — if skills or workflows changed, do templates need updating?
- **README** — does the project description or skill list need updating?

Report anything discussed-but-not-landed that should be captured before the session ends.

## 3. What's next

Propose in two parts:

- **This session** — remaining work in scope, or confirmation that scope is complete
- **Project** — next priorities, upcoming work, anything surfaced during this session that should be tracked

If this is a natural stopping point, say so — and suggest whether `/wrap-up`, `/handover`, or just a commit is appropriate.

## 4. Comments

Brief observations for the user:

- **Going well** — patterns, decisions, or approaches worth preserving
- **Watch** — concerns, rough edges, tech debt introduced, things that might bite later
- **Suggestions** — anything worth raising that doesn't fit above

## Notes

- This skill is non-destructive. It reads and reports; it doesn't edit files, update memory, or commit. Those are follow-up actions the user authorizes.
- If the session is short and simple, some checks may be trivial (e.g., no memory files relevant). Skip sections that have nothing to report rather than padding with "nothing to report."
- The user may invoke this multiple times in a long session. Each invocation covers work since the last checkpoint (or session start).
