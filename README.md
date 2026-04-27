# Cadence

A structured workflow method for long-running Claude Code projects. Session lifecycle, knowledge architecture, onboarding, and templates.

## What it does

Cadence provides universal [Claude Code skills](https://docs.anthropic.com/en/docs/claude-code/skills) that manage the session lifecycle across any project:

- **`/session-start`** — warms context at the beginning of a fresh session. Verifies auto-loaded config, takes a git snapshot, asks for intent, surfaces relevant memory, proposes a plan.
- **`/handover`** — ends a session with work-in-progress. Verifies clean state, updates memory and docs, captures unstarted scope, generates an opening prompt for the next fresh session.
- **`/wrap-up`** — closes a session cleanly without generating an opening prompt. Use when the next work is on a different project.
- **`/next-prompt`** — generates an opening prompt for the next session. Use standalone when the session is already wrapped up.
- **`/pre-commit`** — independent code review before committing. Generates a structured review prompt and runs it through `claude -p` for fresh-context verification.

All skills are project-agnostic. They read context from whatever `CLAUDE.md` and memory the harness auto-loads — no hardcoded project details.

## Install

**Skills only** (just `/session-start` and `/handover`):

```bash
npx skills add rocketmen/cadence -g
```

**Full setup** (user-level CLAUDE.md + skills). Requires a sibling `cadence-private` repo with your filled-in `config/CLAUDE.md` (start from `templates/user-claude.md`):

```bash
./scripts/install.sh        # creates symlinks in ~/.claude/
./scripts/install.sh --force # replaces existing real files (backs up to .bak)
```

## Prerequisites

Cadence skills expect the target project to have:

1. **`CLAUDE.md`** in the project root — project overview, rules, commands, architecture, conventions.
2. **`.claude/memory/`** directory with a `MEMORY.md` index — dynamic knowledge (user profile, feedback, feature state, references).

See `templates/` for starter files, or use `scripts/init-project.sh` to scaffold a new project. For existing projects, see [`docs/migration.md`](docs/migration.md).

## The method

Cadence is built on a three-layer architecture:

| Layer | Purpose |
|---|---|
| **Cadence** (this repo) | Universal philosophy, skills, templates, onboarding |
| **User config** (`~/.claude/`) | Personal rules, tool settings, project memory symlinks |
| **Project repo** | Domain-specific CLAUDE.md, memory, hooks, docs |

The full methodology is documented in `docs/methodology.md`.

## Project status

Universal skills, methodology doc, templates, and onboarding scripts are functional and tested across multiple projects.

## License

MIT
