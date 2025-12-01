---
description: Review uncommitted changes and generate a commit message
model: github-copilot/gpt-4.1
---

# Git Commit Message Guidelines

Review the uncommitted changes in the git working directory and generate a commit message following these rules.

## Context

!`git --no-pager diff`

## Format

```
<type>(<scope>): <summary>

<body>

<footer>
```

## Subject Line
- **Pattern:** `<type>(<scope>): <summary>`
- **Types:** `feat`, `fix`, `docs`, `chore`, `test`, `ci`, `revert`
- **Scope:** Optional, describes affected area (e.g., `auth`, `api`, `deps`)
- **Summary:** Imperative mood, lowercase, ≤50 chars, no period
- **Examples:** `feat(auth): add OAuth support`, `fix(api): handle null responses`

## Body
- Explain **why** the change matters from a user/product perspective
- Focus on impact, not implementation details
- Wrap lines at ~72 characters
- Skip body if summary is self-explanatory

## Footer (Optional)
- **Breaking changes:** `BREAKING CHANGE: <description>`
- **Issue references:** `Refs: #123` or `Closes: #456`
- **Branch convention:** If branch name contains `sc-<number>`, add `Issue: [sc-<number>]`

## Key Principles
- Prefer WHY over WHAT (avoid listing files or diff details)
- Use imperative mood: "add feature" not "added feature"
- One logical change per commit
- Skip implementation details unless critical for understanding

## Examples

```
feat(auth): persist OAuth sessions

Keep users signed in across browser restarts to reduce
re-authentication friction and improve retention.
```

```
fix(search): prevent duplicate results

Deduplicate at aggregator layer to avoid showing users
repeated entries when shards respond out of order.
```

```
chore(deps): bump lodash to 4.17.21

Patch prototype pollution vulnerability.

Issue: [sc-12345]
```

---

**Command:** Always use `git commit --no-verify` to skip pre-commit hooks.
