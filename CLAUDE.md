# CLAUDE.md

This file provides guidance to Claude Code when working with cadence.

## Project

**Cadence** is a formalized Claude Code workflow method — session lifecycle, knowledge architecture, onboarding, and templates — extracted from production use into a reusable system.

Two repos:
- **cadence** (this, public) — universal skills, docs, templates. Installable via `npx skills add rocketmen/cadence`.
- **cadence-private** (private) — personal config, user-level CLAUDE.md content, install/migration scripts.

**Stack:** Markdown skills, shell scripts, no build step.

## Project constellation

| Repo | Role |
|---|---|
| **cadence** (this) | Public skills, docs, templates |
| **cadence-private** (`../cadence-private`) | Personal config, install scripts |

**Target projects** (consumers of cadence skills): tracked in `.claude/memory/`.

## Rules

1. **No personal details in this repo.** This repo goes public. No emails, API keys, personal paths in committed content. Personal config lives in cadence-private. `.claude/memory/` is gitignored and backed up via cadence-private. Before staging, run `/validate-public` to read changed files end-to-end.
2. **npx skills format.** Skills live at `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`). Follow vercel-labs/skills conventions so `npx skills add rocketmen/cadence` works.
3. **Skills must be project-agnostic.** Zero hardcoded project details. Skills read context from auto-loaded CLAUDE.md + MEMORY.md at runtime. If a skill needs project-specific behavior, that behavior belongs in the project's CLAUDE.md rules, not the skill.
4. **Templates are starting points.** Every project customizes. Templates in `templates/` should be minimal and well-commented, not prescriptive.
5. **`docs/methodology.md` is authoritative.** The methodology doc is the single source of truth for the Cadence method. Skills, templates, and README point to it — they don't duplicate it.
6. **Plan mode for non-trivial work.** Enter plan mode for: >3 files, new pattern, cross-repo change, no clear precedent. This project is mostly markdown, but structural changes (new skill, new template category, methodology rewrites) qualify.
7. **Commit discipline.** Trunk-based on `master`. Conventional commits. One concern per commit.

## Commands

No build step. Useful commands:

```bash
# Verify skills format
find skills -name 'SKILL.md' -exec head -5 {} +
```

## Architecture

### Three-layer model

| Layer | Purpose | Owned by |
|---|---|---|
| **Cadence (the method)** | Universal philosophy, skills, templates, onboarding | This repo + cadence-private |
| **User config (`~/.claude/`)** | Personal rules, tool settings, project memory symlinks | Deployed by cadence-private |
| **Project repo** | Domain-specific CLAUDE.md, `.claude/memory/`, hooks, docs | Each project |

### In-repo memory

Each project stores memory at `.claude/memory/` (version-controlled). A symlink at `~/.claude/projects/<path-hash>/memory/` points to the in-repo directory so the harness can find it. Path hash: absolute path with `/` replaced by `-`.

### Skill design

Universal skills (`/session-start`, `/handover`, `/wrap-up`, `/next-prompt`) work by reading whatever CLAUDE.md and MEMORY.md the harness auto-loads. They never reference specific projects, rules, or filenames. Project-specific behavior stays in each project's CLAUDE.md rules.

## Workflow

**RIPER-lite:** Research, Plan, Execute, Review. Plan mode for structural changes (new skill, methodology edits, template redesign).

**Session lifecycle:** `/session-start` at fresh session start. At session end: `/handover` (wrap-up + opening prompt), `/wrap-up` (close without prompt), or `/next-prompt` (prompt only).

**Subagents:** delegate broad exploration to `Explore`, multi-file planning to `Plan`.

## Where knowledge lives

| Location | What |
|---|---|
| **This file** | Rules, constellation, architecture, workflow |
| `docs/methodology.md` | The Cadence method (authoritative reference) |
| `skills/` | Universal session lifecycle skills |
| `templates/` | Starter files for new projects |
| `scripts/` | Automation (init-project, etc.) |
| `.claude/memory/` | Dynamic learnings — feedback, project state, user profile |
| **cadence-private** | Personal config, install scripts, memory backup |

**Decision tree for new knowledge:**
- Immutable project truth or convention → this file
- Methodology principle or process → `docs/methodology.md`
- Correction from user feedback → `.claude/memory/feedback_*.md`
- In-flight feature state → `.claude/memory/project_<feature>.md`
- Repeatable multi-step workflow → `skills/<name>/SKILL.md`
- Personal config → cadence-private
