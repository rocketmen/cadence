---
name: pre-commit
description: Independent code review before committing. Generates structured review prompts covering correctness and compliance, runs them through claude -p for fresh-context verification. Splits multi-concern diffs into focused reviews. Universal — works with any project that has a CLAUDE.md. User-invoked or run at commit time.
---

# /pre-commit

Run an independent review of current changes before committing. A separate Claude process (`claude -p`) reviews the code with fresh context — no shared conversation history, no author bias.

## 1. Gather context

Collect the inputs the reviewer needs:

1. Run `git diff` to get unstaged changes. If files are already staged, also run `git diff --cached`. Combine into a single diff.
2. Run `git diff --name-only` (and `--cached` if staged) to get the list of changed files.
3. Read the project's CLAUDE.md — specifically the **Rules** section. Each numbered rule becomes a compliance check item.
4. Summarize the **intent** — what was implemented and why. Derive this from the conversation context. If unclear, ask the user in one sentence.

## 2. Assess and split

Before constructing prompts, assess whether the diff should be reviewed as one unit or split by concern.

**Split when:** the diff contains multiple distinct changes (e.g., a bug fix + a refactor + a new feature). The intent summary is the guide — if it has multiple numbered items or distinct topics, split along those lines.

**Keep together when:** all changes serve a single concern, even across multiple files.

**For each concern group, identify:**
- The intent (one item from the overall intent)
- The relevant files and their diffs
- Whether repetitive changes across files can be summarized (e.g., "same 4-line guard added to 6 job files — verify the pattern is correct and consistently applied")

## 3. Construct review prompts

Generate one review prompt per concern group. Write each to a unique temp file:

```bash
/tmp/cadence-review-$(basename $PWD)-$$-01.md
/tmp/cadence-review-$(basename $PWD)-$$-02.md
# etc.
```

The `$$` (shell PID) ensures no collision with other sessions. For a single-concern review, just use `-01.md`.

Each prompt uses this template:

```markdown
# Code Review Request

You are reviewing changes to a project. Read the diff carefully and check each item below. You have access to the full project via CLAUDE.md and filesystem — read any file you need for context.

## Intent

{1-2 sentence summary of THIS concern only}

## Changed files

{list of changed file paths for this concern}

## Diff

{git diff output for this concern's files only}

## Review Checklist

### Correctness

For each changed function, method, or logic block:

1. Trace the happy path — does it produce the expected result?
2. Trace error and edge paths — empty input, null, zero, negative, boundary values
3. Check error handling — are errors caught, reported, and recovered from appropriately?
4. Verify the implementation matches the stated intent above
5. Look for off-by-one errors, incorrect comparisons, wrong variable references
6. Check for resource leaks (unclosed files, connections, event listeners)
7. If async code: check for race conditions, missing awaits, unhandled rejections
8. If the change modifies existing behavior: is the modification intentional and complete?

### Compliance

Check the changes against each of these project rules:

{For each numbered rule from CLAUDE.md Rules section, include it here verbatim as a checklist item}

### Omissions

- Did the changes require updates to related files that are missing? (e.g., new skill added but install.sh not updated, rule changed but template still references old rule, new export but index not updated)
- If a `project_<feature>.md` memory file exists for this area, do the changes require updating it?
- Are there documentation files, configs, or tests that should have been updated alongside these changes?

### General

- Read the full file around each changed function or block — bugs often hide in the interaction between changed and unchanged code, not in the diff alone.
- Any dead code or unused imports introduced?
- Are variable and function names clear and consistent with the project's conventions?
- Any obvious simplifications that would preserve behavior?

## Output format

For each finding, output exactly:

- **Severity:** bug | concern | nit
- **Location:** file:line
- **Issue:** one-line description
- **Suggestion:** proposed fix or investigation step

End with a summary block:

## Summary
{total} findings: {N} bug, {N} concern, {N} nit
Checks passed: {list which checklist sections had no findings}

If no issues found, state: "No issues found." followed by a one-line summary of what you verified.

Do not explain your process. Output findings and summary only.
```

## 4. Run the reviews

Run each prompt as a **foreground Bash command** with a 3-minute timeout. Do NOT background it or poll for output — `claude -p` is blocking and returns its output directly to stdout.

```bash
claude -p --model claude-sonnet-4-6 < /tmp/cadence-review-$(basename $PWD)-$$-01.md
```

Set the Bash tool timeout to 180000ms (3 minutes). The output appears as the Bash tool result. No sleep, no polling, no background — just run it and wait.

For multiple concern groups, run each prompt sequentially (one `claude -p` at a time).

**Model selection:**
- **Sonnet** (default) — for focused, single-concern reviews. Cheap and fast.
- **Opus** — for a single complex concern with subtle interactions, or when Sonnet's findings seem shallow. The worker judges; this is not automatic.

The reviewer process loads the project's CLAUDE.md and memory automatically. It can read any file in the project for additional context.

## 5. Present findings

Collect findings across all concern groups. Fix bugs, then present a **consolidated end-of-review summary** to the user. This summary is the primary output — individual per-concern summaries during the review are intermediate.

The end-of-review summary should include:

- Total findings across all concerns, by severity
- What was fixed and what remains for user judgment
- Per-concern one-line status (clean / fixed / needs user input)
- Final recommendation: proceed to commit, or user action needed

Severity handling:

- **Bugs** — fix these before the summary. After fixing, offer to re-run the review for the affected concern.
- **Concerns** — list in the summary for user judgment. May or may not need action.
- **Nits** — note in the summary but don't block the commit.
- **Clean** — proceed to "ready to stage and commit?"

Re-review after fixes is optional — the user decides. Each re-review is a fresh `claude -p` invocation with fresh eyes.

## When to run

- Before every commit, at the "ready to stage and commit?" moment
- After significant implementation work, before proposing the commit
- User's discretion at any time via `/pre-commit`

## Configuration

- **Model:** defaults to `claude-sonnet-4-6`. Use `claude-opus-4-6` for complex single-concern reviews.
- **Scope:** reviews whatever `git diff` shows. Stage files first to control scope.
- **Project rules:** derived from CLAUDE.md Rules section. More rules = more thorough compliance checks.

## Notes

- The reviewer has no access to the current conversation — it starts fresh. This is the point: fresh context escapes the author's confirmation bias.
- The reviewer CAN read any file in the project (it has full tool access). The diff is the starting point, not the boundary.
- For non-code projects, the correctness checklist may not apply. The compliance and general checks still provide value.
- Token cost per review is low with Sonnet (~$0.01–0.05 per concern group).

## Anti-patterns

- **Don't skip review for "small" changes.** Small changes can have large impact. The cost is low enough to run every time.
- **Don't treat "no issues found" as proof of correctness.** The review catches what it catches. Tests, manual verification, and user judgment still matter.
- **Don't loop indefinitely on nits.** Fix bugs, consider concerns, note nits. Ship when bugs are fixed.
- **Don't send a 6-concern diff as one prompt.** Split it. Focused reviews catch more than overloaded ones.
