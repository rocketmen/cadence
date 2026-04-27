# CLAUDE.md — user-level preferences

Cross-project rules for <your-name> (<your-email>). Applies alongside per-project CLAUDE.md and memory.

## About me

<Your role, projects, and expertise. Examples:>
<- Solo developer across several Claude Code projects>
<- Sophisticated CC user — don't explain standard language/framework patterns>
<- Per-project `memory/user_profile.md` has role + technical-depth specifics>

## Rules

1. **Never stage or commit without explicit permission.** Plan-level approvals ("go ahead", "sounds good") do NOT carry commit authority. After finishing edits, stop and ask "Ready for me to stage and commit?" or propose the message for review. Only exception: the current-turn instruction explicitly says "stage and commit", "commit this", or equivalent.

2. **State a lean when offering choices.** Every choice — architectural or small — comes with a preferred option and a brief reason. Neutral "A or B?" forces you to do analysis I'm better positioned to do first. If genuinely 50/50, say so explicitly; don't pretend.

3. **Autonomous bug fixing.** Don't ask for info already in the bug report. Read the logs/tests provided and find the root cause yourself.

4. **Step-by-step review over batch-apply.** For non-trivial changes, chunk with review points. Five small approvals beat one big apology.

5. **Keep `project_<feature>.md` current.** If work substantially changes the state of a feature that has a `memory/project_<feature>.md` file, update it (current state + next steps) before session end — at commit time or at `/handover`.

6. **Structured summaries after work chunks.** After creating or modifying files, summarize: what changed (file paths), verifiable claims, design decisions, and what was deferred. Skip for pure discussion or research turns.

## Cadence foundations

These principles shape how every session should approach knowledge and tooling:

- **CLAUDE.md is minimal rules + pointers.** Target ≤150 lines per project. Exclude standard practices, long explanations, duplicated content.
- **Memory holds dynamic knowledge.** `MEMORY.md` is a pure index — no inline content. Typed files: `feedback_*`, `project_*`, `reference_*`, `user_*`.
- **One home per piece of knowledge.** If something lives in two places, one is canonical and the other is a pointer. Drift kills long-lived setups.
- **Skills formalize repeatable workflows.** 3+ recurrences before skill-ifying. Below that, prompts suffice.
- **Hooks enforce the deterministic.** Don't automate judgment calls. Hooks are yes/no gates only.

## Collaboration flow

- **Research → discuss → propose → decide.** I drive; you propose with leans at decision points.
- **Fresh sessions preferred** over compact. Use CLAUDE.md + memory + handover opening prompts for deterministic context.
- **Plan mode** for non-trivial work (new pattern, cross-repo, no clear precedent, multiple files). Project CLAUDE.md may narrow the triggers.
- **Subagents** — delegate broad codebase exploration to `Explore`, multi-file planning to `Plan`. Keeps main context clean.
- **Session lifecycle:** `/session-start` at fresh session start. `/checkpoint` for mid-session reflection. At session end: `/handover` (wrap-up + opening prompt), `/wrap-up` (close without prompt), or `/next-prompt` (prompt only). `/pre-commit` for independent review before committing.

## Where knowledge lives

When new knowledge emerges, place it by type:

1. Deterministic + automatable → hook (`.claude/settings.json`)
2. Immutable project truth → project CLAUDE.md
3. User feedback / validated choice → `.claude/memory/feedback_*.md`
4. In-flight feature state → `.claude/memory/project_<feature>.md`
5. External pointer → `.claude/memory/reference_*.md`
6. User preference (cross-project) → this file
7. Long-form pattern → `docs/<topic>.md`
8. Repeatable workflow (≥3×) → `.claude/skills/<name>/SKILL.md`
9. One-off fact → don't document

## Anti-patterns

- **Bloated CLAUDE.md** — over 200 lines is a smell; trim and link out
- **Pasting orientation every session** — if repeated, it belongs in CLAUDE.md or a skill
- **Ambiguous authorship** — make explicit whether Claude executes or the user does
