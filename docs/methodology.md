# The Cadence Method

A structured approach to long-running Claude Code collaboration. Works best for solo or small-team projects, long-running codebases, and work that spans multiple Claude sessions. Adopt whole or in pieces.

---

## Philosophy

Seven core principles.

1. **Fresh sessions beat compact.** Compact is a lossy, opaque summary. A fresh session with CLAUDE.md + memory + opening prompt gives deterministic, auditable context. Use compact only when a single task genuinely needs continuity beyond the window.

2. **CLAUDE.md is minimal rules + pointers, not a manual.** Target ≤150 lines. Include: critical non-obvious rules, project constellation, commands, architecture-at-a-glance, conventions that differ from framework defaults. Exclude: standard practices, long-form explanations, duplicated content.

3. **Memory holds dynamic knowledge.** User profile, corrections, per-feature state, external pointers. Indexed by a `MEMORY.md` that is a pure index — no inline content.

4. **Skills formalize repeatable workflows.** If you've done the same multi-step ritual three times, skill-ify it. Below that bar, prompts suffice. Skills have maintenance cost.

5. **Hooks enforce the deterministic.** Don't automate judgment calls. Hooks are yes/no gates for things that should always happen — blocking `.env` writes, pre-commit test gates, compaction re-injection.

6. **One home per piece of knowledge.** If a rule lives in two places, one is canonical and the other is a pointer. Drift is what kills long-lived Claude Code setups. The decision tree below enforces single-home-per-rule.

7. **User drives; Claude proposes with leans.** Claude never asks "A or B?" neutrally — always states a preferred choice and reason. User accepts, pushes back, or asks for more detail. Neutral options force the user to do analysis Claude is better positioned to do first.

---

## The three-layer model

Cadence organizes knowledge into three layers, each with a distinct owner:

| Layer | Purpose | Owned by |
|---|---|---|
| **Cadence** (this repo) | Universal philosophy, skills, templates, onboarding | The Cadence method |
| **User config** (`~/.claude/`) | Personal rules, tool settings, cross-project preferences | The individual developer |
| **Project repo** | Domain-specific CLAUDE.md, memory, hooks, docs | Each project |

The layers stack: project rules override user config, which overrides Cadence defaults. Each layer has a single owner — if a rule appears in two layers, one is canonical and the other is a pointer.

### Within-project weight

Inside a project, knowledge artifacts carry different weight:

| Layer | Purpose | Weight |
|---|---|---|
| **CLAUDE.md "Rules"** | Immutable project truths | MUST |
| **CLAUDE.md "Conventions"** | Project-wide defaults | SHOULD |
| **Hooks** (`.claude/settings.json` + git hooks) | Deterministic enforcement | MUST (enforced) |
| **Memory `feedback_*`** | Corrections + validated choices | SHOULD |
| **Memory `project_*`** | In-flight feature state | Reference |
| **Memory `reference_*`** | External pointers | Reference |
| **Memory `user_*`** | User profile / communication | Reference |
| **`docs/` in repo** | Long-form patterns, architecture | Reference |
| **Skills** (`.claude/skills/`) | Repeatable multi-step workflows | Workflow |

Placement encodes weight. No parallel MUST/SHOULD/MAY tagging needed.

---

## Decision tree — where does new knowledge go?

When a new rule, learning, or artifact emerges:

1. **Deterministic and automatable?** → Hook (`.claude/settings.json` or git hook)
2. **Immutable project truth or convention?** → CLAUDE.md
3. **Correction from user feedback / validated choice?** → `memory/feedback_*.md`
4. **In-flight feature state?** → `memory/project_<feature>.md`
5. **External pointer (path, URL, dashboard)?** → `memory/reference_*.md`
6. **User role or communication preference?** → `memory/user_profile.md` (or `~/.claude/CLAUDE.md` if truly cross-project)
7. **Long-form pattern or architecture?** → `docs/<topic>.md` (+ entry in `docs/README.md`)
8. **Repeatable multi-step workflow (≥3 recurrences)?** → `.claude/skills/<name>/SKILL.md`
9. **One-off fact that won't recur?** → Don't document

---

## Session workflow

### Default: fresh session per work unit

A "work unit" is a single feature, bug fix, or focused exploration. Don't extend sessions past natural seams: commit boundary, sub-task complete, topic shift.

### RIPER-lite phases

Four phases inside a work unit:

1. **Research** — understand the problem. Read relevant code, check docs, study legacy counterparts if applicable.
2. **Plan** — enter plan mode for any of: >3 files, new pattern, cross-repo change, no clear precedent. Multi-session work gets a `project_<feature>.md` memory file.
3. **Execute** — implement per plan. Track with tasks.
4. **Review** — run tests, lint, visual check for UI. Run `/pre-commit` for independent verification (correctness + compliance via `claude -p`). Propose commit; wait for user approval.

### Session bookends

- **`/session-start`** at the beginning of a fresh session. See [`skills/session-start/SKILL.md`](../skills/session-start/SKILL.md).
- **`/handover`** at the end of an in-progress session — wraps up and generates an opening prompt. See [`skills/handover/SKILL.md`](../skills/handover/SKILL.md).
- **`/wrap-up`** — closes a session cleanly without generating an opening prompt. Use when the next work is on a different project. See [`skills/wrap-up/SKILL.md`](../skills/wrap-up/SKILL.md).
- **`/next-prompt`** — generates an opening prompt only. Use when the session is already wrapped up. See [`skills/next-prompt/SKILL.md`](../skills/next-prompt/SKILL.md).

Sessions without in-flight work end with: commit + cleanup. No wrap-up ritual needed.

### Mid-session checkpoint

- **`/checkpoint`** — mid-session reflection. Summarizes work so far, checks memory and docs for staleness, proposes next steps. See [`skills/checkpoint/SKILL.md`](../skills/checkpoint/SKILL.md).

Use at natural pause points: after a chunk of work, before deciding what to do next, or when the session has gone long enough to warrant orientation. Non-destructive — reports findings, doesn't modify files.

### Context pressure

Use qualitative cues, not percentages. Claude flags opportunities:
- Commit boundary
- Sub-task complete
- Topic shift
- Quality degradation (Claude's own judgment)

User decides when to close. For large-context models, natural seams land well before any percentage-based threshold.

---

## Review patterns

Verification happens after Execute, before committing. Four types of verification serve different purposes:

| Type | What | Method | Trigger | Frequency |
|---|---|---|---|---|
| **Correctness** | Bugs, edge cases, logic errors | `claude -p` (fresh context) | Pre-commit | Every significant change |
| **Consistency** | Memory/docs match reality | Subagent (fresh context) | Session start + end | Every session |
| **Compliance** | Project rules followed | `claude -p` (with correctness) | Pre-commit | Every commit |
| **Design** | Right approach, right problem | Interactive session | After major deliverables | As needed |

### Independent review via `claude -p`

The worker session generates a structured review prompt and runs it through `claude -p` — a separate Claude process with fresh context. The reviewer loads CLAUDE.md and memory automatically but shares no conversation history with the worker. This escapes the author's confirmation bias: the worker spent 20 minutes convincing itself the code works; a fresh reader traces paths without those assumptions.

The `/pre-commit` skill handles correctness + compliance in a single `claude -p` pass. See [`skills/pre-commit/SKILL.md`](../skills/pre-commit/SKILL.md).

**Cost model:** using a smaller model (e.g., Sonnet) for reviews keeps token cost negligible (~$0.01–0.05 per review). At this cost, running reviews on every commit is practical.

### Consistency checking

Memory drift — where `project_<feature>.md` says one thing but git history shows another — causes the next session to plan based on stale assumptions. `/session-start` includes a freshness check: after surfacing memory, a subagent compares feature state claims against recent git log and flags discrepancies. The subagent runs independently because the main session has already absorbed the memory claims and may be anchored to them.

False positives are acceptable — the goal is surfacing obvious drift, not proving correctness.

### Design review

Design review evaluates whether the approach is right, not just whether the code works. It's the most judgment-heavy type and benefits most from full independence.

**Two-phase pattern:**

1. **Intent sync** (interactive, human involved) — ensure the reviewer understands the goal, constraints, and context. This is where the reviewer asks "why not X instead?" and gets answers.
2. **Structured checks** (procedural, automatable) — once intent is clear, verify: does implementation match plan? Are there simpler alternatives? Will this scale? Does this follow best practices for the domain? Is there unnecessary coupling?

Phase B resembles a compliance check with research — the gap between design review and compliance narrows as a project matures and accumulates more documented patterns.

**When to invoke:** after major deliverables (new skill, new pattern, architectural decisions). Not every commit — the cost and signal-to-noise ratio don't justify it.

**Method:** separate interactive Claude Code session, or Agent Teams for native multi-agent collaboration. `claude -p` works for a first pass but can't do back-and-forth.

### Domain specificity

Correctness and compliance checks are domain-specific. For coding projects: bugs, best practices, modern patterns, performance. For non-coding projects: different quality standards apply. The `/pre-commit` skill reads CLAUDE.md and adapts — project rules drive the compliance checklist, not hardcoded coding assumptions. The correctness checklist in the review prompt template is coding-oriented; non-code projects can skip or adapt it.

---

## Setup playbook — adopting this for a new project

Steps are ordered; do them top-down.

### 1. Inventory the project

Before writing anything, collect:

- Stack (framework, build tool, test runner, package manager)
- Constellation (adjacent repos, legacy apps, backends, sister apps)
- Existing docs (what's already documented)
- Conventions that differ from framework defaults
- Any pre-existing Claude Code config (`.claude/`, CLAUDE.md, memory)

### 2. Draft CLAUDE.md

Target ≤150 lines. Suggested structure:

- **Project** — one-paragraph overview + stack
- **Project constellation** (if multi-repo) — table of adjacent repos with paths + roles
- **Rules** — 5–10 numbered MUSTs (non-obvious, project-critical)
- **Commands** — cheat-sheet of frequent shell commands
- **Testing** — stack, scope, patterns, triggers
- **Environment** — runtime version, package manager, local domain, env file pointers
- **Local development quirks** — anything unusual (linked local packages, etc.)
- **Architecture** — entry flow, routing, auth, state, HTTP, key integrations
- **Conventions** — only things that differ from framework defaults
- **Workflow** — RIPER-lite summary + pointer to `/session-start` and `/handover`
- **Where knowledge lives** — layer table + decision tree

Use pointers (links) liberally. Don't inline long explanations. See `templates/` for a starter skeleton.

### 3. Set up memory

Project memory lives at `.claude/memory/` in the project repo. A symlink at `~/.claude/projects/<path-hash>/memory/` points to it so the Claude Code harness can find it. The path hash is the project's absolute path with `/` replaced by `-` (e.g., `/Users/me/projects/my-app` → `-Users-me-projects-my-app`). See `scripts/init-project.sh` to automate this.

**Private repos:** commit `.claude/memory/` directly — version-controlled naturally with the project.

**Public repos:** gitignore `.claude/memory/` (it may contain personal details) and back up via a separate mechanism.

Pre-populate:

- `MEMORY.md` — pure index, one-line entries per memory file
- `user_profile.md` — role, working style, technical depth, collaboration preferences
- `archive/` — empty directory for completed `project_<feature>.md` files

Add `feedback_*.md` and `project_*.md` entries as they arise — don't pre-create empty ones.

### 4. Write `docs/README.md`

In the project repo, create a minimal index:

- One-line entry per doc: *"consult when X"*
- Pointer to CLAUDE.md for the repo constellation
- No duplication of content — link out

### 5. Install skills

```bash
npx skills add rocketmen/cadence -g
```

This installs `/session-start` and `/handover` at user level (`~/.claude/skills/`), available in every project. Add project-specific skills only when friction surfaces.

### 6. Add hooks

Claude Code hooks in `.claude/settings.json` for tool-level gates (e.g., block writes to `.env`). Git hooks for commit-level gates (format, lint, project-specific checks).

Rule: hook only when the check is deterministic. Judgment calls belong in CLAUDE.md rules or skills.

### 7. Handle `.claude/` and `.gitignore`

If global `~/.gitignore` ignores `.claude/`, force-include in project `.gitignore`:

```
# Claude Code — force-include project config (override global ignore)
!.claude/
!.claude/**
.claude/settings.local.json
```

If global doesn't ignore `.claude/`, just add `.claude/settings.local.json`.

For **public repos**, also gitignore `.claude/memory/` (it may contain personal details). For **private repos**, commit it — version control is the point.

### 8. Verify the setup

- `git check-ignore .claude/settings.json` should NOT be ignored
- `git check-ignore .claude/settings.local.json` SHOULD be ignored
- Run your package manager's install to register git hooks
- Try a fresh session with `/session-start` — does it do what you expect?

---

## Cross-project vs project-scoped

Expanding on the three-layer model — what lives where:

| Artifact | Project-scoped | User-scoped (`~/.claude/`) |
|---|---|---|
| **CLAUDE.md** | Project rules, conventions, architecture | Cross-project rules, communication style |
| **Skills** | `.claude/skills/` — project-specific workflows | `~/.claude/skills/` — universal workflows (e.g., Cadence skills) |
| **Settings** | `.claude/settings.json` — project hooks, permissions | `~/.claude/settings.json` — global hooks (use carefully) |
| **Memory** | `.claude/memory/` — per-project dynamic knowledge | N/A (memory is always per-project) |
| **Docs** | `docs/` — project patterns, architecture | `~/.claude/docs/` — methodology, reference |

### What Claude Code does NOT provide

- **Cross-project auto-memory.** Memory is per-project. Universal preferences → `~/.claude/CLAUDE.md` or user skills.
- **Automatic team sync.** Sharing setups across members requires a shared repo or package.

---

## Anti-patterns

- **Bloated CLAUDE.md.** Over 200 lines is a smell. Trim ruthlessly — link out for detail.
- **Duplicated knowledge.** Same rule in CLAUDE.md + memory + docs guarantees drift. Pick one home.
- **Skill-ifying everything.** Skills have maintenance cost. Rule of thumb: 3+ recurrences before codifying.
- **Hook-ifying judgment calls.** Hooks should be yes/no. Anything requiring nuance belongs in CLAUDE.md rules or skills.
- **Relying on compact.** Lossy; opaque. Fresh session + durable artifacts is more reliable and auditable.
- **Auto-committing.** Always get user approval. Claude proposes, user commits.
- **Batch changes without review.** Chunk-by-chunk with review catches issues early. Five separate approvals beat one big apology.
- **Pasting orientation on every session.** If you're pasting the same preamble repeatedly, it belongs in CLAUDE.md or a `/session-start` skill.
- **Ambiguous authorship in instructions.** When CLAUDE.md describes a flow, make it explicit whether Claude executes or the user does.

---

## Evolution

This methodology is a living document. Expect to refine as you use it:

- First-time use of `/session-start` and `/handover`: expect shakedown runs. Tune the SKILL.md files based on friction.
- Templates: starting points, not final. Every project customizes.
- Cross-project lift: as universal rules become obvious (e.g., "always use conventional commits"), migrate them from per-project CLAUDE.md to `~/.claude/CLAUDE.md`.
- When the methodology itself needs updating, update this doc — it's the single source of truth.

---

## Credits

Influenced by:

- The RIPER pattern from the Claude Code community (Research / Innovate / Plan / Execute / Review — simplified here to RIPER-lite)
- Anthropic's best-practices documentation on CLAUDE.md sizing and memory organization
