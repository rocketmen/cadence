# CLAUDE.md

This file provides guidance to Claude Code when working with <project-name>.

## Project

<one-paragraph overview + stack>

## Project constellation

<!-- Remove this section for single-repo projects -->

| Repo | Path | Role |
|---|---|---|
| **<this-repo>** | `<path>` | <role> |
| <adjacent-repo> | `<path>` | <role> |

## Rules

1. **<Rule 1>.** <explanation>
2. **<Rule 2>.** <explanation>

## Commands

```bash
<cheat-sheet of frequent shell commands>
```

## Testing

**Stack:** <test runner + frameworks>
**Scope:** <what to test, what not to test>
**Pattern:** <helpers, mocking, fixtures>
**When to run / write:** <triggers>

## Environment

<runtime version, package manager, local domain, env file pointers>

## Local development quirks

<!-- Remove this section if nothing unusual -->

<linked local packages, special setup steps, etc.>

## Architecture

<entry flow, routing, auth, state management, HTTP layer, key integrations>

## Conventions

<!-- Only things that differ from framework defaults -->

<formatting, path aliases, naming patterns>

## Workflow

**RIPER-lite:** Research, Plan, Execute, Review. Plan mode for: >3 files, new pattern, cross-repo change, no clear precedent.

**Session lifecycle:** `/session-start` at fresh session start. `/checkpoint` for mid-session reflection. At session end: `/handover` (wrap-up + opening prompt), `/wrap-up` (close without prompt), or `/next-prompt` (prompt only). `/pre-commit` for independent review before committing.

**Subagents:** delegate broad codebase exploration to `Explore`, multi-file planning to `Plan`.

## Where knowledge lives

| Location | What |
|---|---|
| **This file** | Rules, constellation, architecture, workflow |
| `docs/` | Long-form patterns, architecture docs |
| `.claude/memory/` | Dynamic learnings — feedback, project state, user profile |
