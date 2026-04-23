---
name: next-prompt
description: Generate an opening prompt for the next fresh session on this project. Produces a copy-pasteable block with orientation, git state, task scope, and execution ask. Use /handover for the full wrap-up + prompt. Universal — works with any project that has a CLAUDE.md and memory setup. User-invoked.
---

# /next-prompt

Generate a copy-pasteable opening prompt for the next fresh session on this project. Use this standalone when the session is already wrapped up (memory current, state clean) but you need a prompt. For the full wrap-up + prompt, use `/handover` instead.

## 1. Gather context

Before generating the prompt, confirm you have:

- The current git state (branch, latest commit hash + subject, clean/dirty)
- The agreed next-session scope (from conversation or `project_<feature>.md`)
- Any design constraints or decisions the next session needs to know

If any of these are unclear, ask the user before generating.

## 2. Generate opening prompt

A copy-pasteable block the user gives the next fresh session. Structure:

1. **Orientation ask** — _"Summarize the project from CLAUDE.md + docs + memory."_ Forces the new session to read durable artifacts before acting.
2. **Git state snapshot** — branch, sync status, latest commit (hash + subject). Saves the next session a tool call.
3. **This session's task** — the agreed next-session scope, concrete enough that the new session can plan without re-deriving. Include file estimates, design constraints, anything surfaced in prior discussion.
4. **Execution ask** — _"Draft a formal plan"_ or _"Execute phase X"_, depending on whether the plan is already approved.

The prompt must be self-contained. A new Claude reading only this prompt + auto-loaded CLAUDE.md + memory should have everything needed to start working. No implicit references to "what we discussed earlier".

## Anti-patterns

- **Don't dump raw conversation history into the opening prompt.** It's a curated summary, not a transcript.
- **Don't assume the next session remembers anything.** Every piece of context must be in the prompt or in durable artifacts (CLAUDE.md, memory, docs).
