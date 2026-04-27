---
name: pre-commit
description: Independent code review before committing. Generates a structured review prompt covering correctness and compliance, runs it through claude -p for fresh-context verification. Universal — works with any project that has a CLAUDE.md. User-invoked or run at commit time.
---

# /pre-commit

Run an independent review of current changes before committing. A separate Claude process (`claude -p`) reviews the code with fresh context — no shared conversation history, no author bias.

## 1. Gather context

Collect the inputs the reviewer needs:

1. Run `git diff` to get unstaged changes. If files are already staged, also run `git diff --cached`. Combine into a single diff.
2. Run `git diff --name-only` (and `--cached` if staged) to get the list of changed files.
3. Read the project's CLAUDE.md — specifically the **Rules** section. Each numbered rule becomes a compliance check item.
4. Summarize the **intent** — what was implemented and why. Derive this from the conversation context. If unclear, ask the user in one sentence.

## 2. Construct review prompt

Write the following template to `/tmp/cadence-review.md`, filling in the placeholders:

```markdown
# Code Review Request

You are reviewing changes to a project. Read the diff carefully and check each item below. You have access to the full project via CLAUDE.md and filesystem — read any file you need for context.

## Intent

{1-2 sentence summary of what was implemented and why}

## Changed files

{list of changed file paths}

## Diff

{full git diff output}

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

## 3. Run the review

```bash
claude -p --model claude-sonnet-4-6 < /tmp/cadence-review.md
```

The reviewer process loads the project's CLAUDE.md and memory automatically. It can read any file in the project for additional context.

If the diff is very large (>500 lines), consider reviewing in chunks — split by file or logical unit, run multiple `claude -p` passes.

## 4. Present findings

Show the reviewer's output to the user. Categorize by severity:

- **Bugs** — fix these before committing. After fixing, offer to re-run the review.
- **Concerns** — present to user for judgment. May or may not need action.
- **Nits** — note them but don't block the commit.
- **Clean** — proceed to "ready to stage and commit?"

Re-review after fixes is optional — the user decides. Each re-review is a fresh `claude -p` invocation with fresh eyes.

## When to run

- Before every commit, at the "ready to stage and commit?" moment
- After significant implementation work, before proposing the commit
- User's discretion at any time via `/pre-commit`

## Configuration

- **Model:** defaults to `claude-sonnet-4-6` for cost efficiency. Override by editing the `claude -p` command (e.g., `claude-opus-4-6` for thorough review of critical changes).
- **Scope:** reviews whatever `git diff` shows. Stage files first to control scope.
- **Project rules:** derived from CLAUDE.md Rules section. More rules = more thorough compliance checks.

## Notes

- The reviewer has no access to the current conversation — it starts fresh. This is the point: fresh context escapes the author's confirmation bias.
- The reviewer CAN read any file in the project (it has full tool access). The diff is the starting point, not the boundary.
- For non-code projects, the correctness checklist may not apply. The compliance and general checks still provide value.
- Token cost per review is low with Sonnet (~$0.01–0.05 depending on diff size).

## Anti-patterns

- **Don't skip review for "small" changes.** Small changes can have large impact. The cost is low enough to run every time.
- **Don't treat "no issues found" as proof of correctness.** The review catches what it catches. Tests, manual verification, and user judgment still matter.
- **Don't loop indefinitely on nits.** Fix bugs, consider concerns, note nits. Ship when bugs are fixed.
