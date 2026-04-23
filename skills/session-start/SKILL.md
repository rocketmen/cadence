---
name: session-start
description: Warm context at the start of a fresh session. Verifies auto-loaded context, runs git snapshot, asks for session intent, surfaces relevant memory, proposes a plan. Universal — works with any project that has a CLAUDE.md and memory setup. User-invoked only.
---

# /session-start

Execute these steps in order to warm context for a fresh session. Do not start implementation until the user confirms scope.

## 1. Verify auto-loaded context

CLAUDE.md and MEMORY.md should already be loaded by the harness. Verify you can recall:

- The project name and purpose (from CLAUDE.md header)
- The project's rules (confirm they exist; do not enumerate them back)
- The memory index (confirm MEMORY.md is loaded and has entries)

If anything is missing or seems unloaded, stop and tell the user — the harness may not have loaded them.

## 2. Git snapshot

Run in parallel:

- `git status`
- `git log --oneline -10`

Summarize in 1-2 sentences: branch, clean/dirty state, recent commit topics. Flag anything unusual (detached HEAD, many uncommitted changes, unexpected branch).

## 3. Ask for intent

One short question: _"What are we working on this session?"_

## 4. Surface relevant memory

Once intent is known, scan the MEMORY.md index for entries relevant to the stated intent:

- **Always read:** `user_profile.md` (if it exists)
- **Match by topic:** `feedback_*` entries whose descriptions relate to the intent
- **In-flight features:** if intent matches a `project_<feature>.md` entry, read it in full
- **References:** `reference_*` entries if the intent touches external systems or cross-repo work

Read full file content for matched entries — do not rely on MEMORY.md one-line descriptions alone. Tell the user which entries you loaded.

## 5. Propose plan or clarify

Based on intent + surfaced memory:

- **Clear, small scope** (single session, precedent exists): propose an inline plan
- **Non-trivial** (multi-file, new pattern, cross-repo, no clear precedent): enter plan mode with a formal plan
- **Unclear scope**: ask clarifying questions first

Wait for user approval before implementation.

## Notes

- Do not re-read CLAUDE.md or MEMORY.md — they are auto-loaded
- Do not read all memory files eagerly — only those relevant to the stated intent
- If the user invokes this mid-session, still execute the steps (user knows what they want)
- Project-specific verification (e.g., checking particular rules, constellation details) belongs in the project's CLAUDE.md, not this skill
