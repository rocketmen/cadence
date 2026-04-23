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

## Collaboration flow

- **Research → discuss → propose → decide.** I drive; you propose with leans at decision points.
- **Fresh sessions preferred** over compact. Use CLAUDE.md + memory + handover opening prompts for deterministic context.
- **Plan mode** for non-trivial work (new pattern, cross-repo, no clear precedent, multiple files). Project CLAUDE.md may narrow the triggers.
- **Subagents** — delegate broad codebase exploration to `Explore`, multi-file planning to `Plan`. Keeps main context clean.

## Where knowledge lives

- **Universal rules / my profile** → this file
- **Project-specific rules, commands, architecture** → `<project>/CLAUDE.md`
- **Dynamic per-project knowledge (feedback, project state, references)** → `.claude/memory/` (in-repo, symlinked from `~/.claude/projects/<path-hash>/memory/`)
