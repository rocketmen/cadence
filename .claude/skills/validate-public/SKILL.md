---
name: validate-public
description: Read changed files end-to-end before committing to verify no personal details leaked into the public cadence repo. Run automatically before staging.
---

# /validate-public

Run this before staging and committing to the cadence repo. Checks changed files for personal details that shouldn't be in a public repo.

## Why read, not grep

Grep only catches patterns you anticipated. Reading end-to-end catches project names, specific counts, contextual hints, personal paths, and anything you didn't think to search for.

## Steps

1. Run `git diff --name-only` to get the list of changed files (unstaged). If files are already staged, also run `git diff --cached --name-only`.

2. Read each changed file end-to-end. For each file, check for:
   - **Email addresses** — no personal or work emails
   - **Personal paths** — no `/Users/<name>/`, home directory references, or machine-specific paths
   - **Project names** — no names of private consumer projects (these are private context)
   - **Specific counts** — avoid exact numbers that reveal private scope (e.g., "4 projects" — use "multiple projects" instead)
   - **API keys, tokens, secrets** — nothing credential-shaped
   - **Usernames, handles, org names** — nothing that identifies the author beyond what's already public in the repo (git config, LICENSE, etc.)

3. Report findings with file path and line number. If clean, confirm explicitly.

## Scope

Only changed files — not the whole repo. The repo was verified clean at initial publish; this catches regressions.

## When to run

Before every commit to this repo. CLAUDE.md Rule 1 requires it.
