# Adopting Cadence in a project

Two paths depending on whether the project already has code and Claude Code config.

---

## Greenfield — new project, no existing config

Run `init-project.sh` from the project root:

```bash
# Private repo (memory committed with the project)
/path/to/cadence/scripts/init-project.sh

# Public repo (memory gitignored, backed up separately)
/path/to/cadence/scripts/init-project.sh --public
```

This creates:

- `CLAUDE.md` from `templates/project-claude.md`
- `.claude/memory/MEMORY.md` from `templates/memory.md`
- `.claude/memory/user_profile.md` from `templates/user_profile.md`
- `.claude/memory/archive/` directory
- Symlink at `~/.claude/projects/<path-hash>/memory/` → `.claude/memory/`
- `.gitignore` entries for `settings.local.json` (and `.claude/memory/` if public)

Fill in the placeholders in CLAUDE.md and user_profile.md. Done.

---

## Brownfield — existing project, possibly existing config

Work through these steps. Skip any that don't apply.

### 1. Inventory what exists

Check for pre-existing Claude Code artifacts:

```bash
ls -la CLAUDE.md                          # project-level config
ls -la .claude/                           # settings, memory, skills
ls -la ~/.claude/projects/$(pwd | tr '/' '-')/memory/  # harness memory location
```

### 2. CLAUDE.md

**No existing CLAUDE.md:** copy `templates/project-claude.md`, fill in placeholders.

**Existing CLAUDE.md:** review against the template structure. Key things to check:

- **Rules section** — are rules numbered, non-obvious, project-critical? Move standard practices out.
- **Line count** — target ≤150 lines. If over, extract long-form content to `docs/` and link.
- **Where knowledge lives** — add the layer table if missing. Establishes the decision tree.
- **Workflow section** — add RIPER-lite summary and `/session-start` + `/handover` pointers.

Don't rewrite a working CLAUDE.md wholesale. Add the structural pieces, trim the bloat.

### 3. Memory

**No existing memory anywhere:** create from scratch:

```bash
mkdir -p .claude/memory/archive
cp /path/to/cadence/templates/memory.md .claude/memory/MEMORY.md
cp /path/to/cadence/templates/user_profile.md .claude/memory/user_profile.md
```

**Memory exists at `~/.claude/projects/<hash>/memory/` (real directory):** move it into the project repo, then replace with a symlink:

```bash
HASH=$(pwd | tr '/' '-')
HARNESS_DIR="$HOME/.claude/projects/$HASH"

# Move memory into the project
mv "$HARNESS_DIR/memory" .claude/memory

# Replace with symlink
ln -s "$(pwd)/.claude/memory" "$HARNESS_DIR/memory"
```

Review the moved files — add `MEMORY.md` if missing, ensure files have YAML frontmatter (`name`, `description`, `type`).

**Memory already at `.claude/memory/`:** verify the symlink exists:

```bash
HASH=$(pwd | tr '/' '-')
ls -la "$HOME/.claude/projects/$HASH/memory"
# Should be a symlink to .claude/memory/
```

### 4. Symlink

If the symlink doesn't exist yet:

```bash
HASH=$(pwd | tr '/' '-')
mkdir -p "$HOME/.claude/projects/$HASH"
ln -s "$(pwd)/.claude/memory" "$HOME/.claude/projects/$HASH/memory"
```

### 5. `.gitignore`

Always ignore local settings:

```
.claude/settings.local.json
```

For **public repos**, also ignore memory (it may contain personal details):

```
.claude/memory/
```

If your global `~/.gitignore` ignores `.claude/`, force-include in the project:

```
!.claude/
!.claude/**
.claude/settings.local.json
```

### 6. Install skills

If not already installed globally:

```bash
npx skills add rocketmen/cadence -g
```

### 7. Verify

```bash
git check-ignore .claude/settings.json          # should NOT be ignored
git check-ignore .claude/settings.local.json     # SHOULD be ignored
readlink ~/.claude/projects/$(pwd | tr '/' '-')/memory  # should point to .claude/memory/
```

Start a fresh session and run `/session-start` to confirm everything loads.

---

## What NOT to migrate

- **Conversation history** — doesn't transfer. Context lives in CLAUDE.md + memory + opening prompts.
- **settings.local.json** — machine-specific, not portable.
- **Stale memory files** — if a `project_<feature>.md` describes completed work, archive or delete it. Don't carry forward dead state.
