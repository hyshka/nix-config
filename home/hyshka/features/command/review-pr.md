---
description: Review a pull request
model: github-copilot/claude-sonnet-4.5
---

Review the pull request using GitHub MCP tools and provide actionable feedback following our team guidelines.

## Context

[Provide PR URL, e.g., https://github.com/owner/repo/pull/123]

## Review Checklist

**Before Code Review:**
- Verify title and description clearly explain the change and rationale
- Confirm functionality aligns with stated goals
- Check if PR should be split into smaller, focused changes (e.g., separate refactors from features)

**Code Review:**
1. **Correctness**: Logic errors, edge cases, potential bugs
2. **Testing**:  Adequate test coverage for new/modified functionality
3. **Maintainability**: Clear naming, readable structure, code duplication
4. **Architecture**: Alignment with broader system design
5. **Best Practices**: Language conventions (Python/JavaScript), security, error handling
6. **Comments**: Outdated comments that don't match code changes

**Performance**:  Flag significant concerns only

## Feedback Guidelines

**Clarity:**
- Use specific function/variable names, not pronouns
  - ❌ "This needs type hints"
  - ✅ "add_cookies_to_ice_cream needs type hints"
- Reference exact code locations
- Make blocking vs. non-blocking feedback explicit

**Tone:**
- Ask open-ended questions:  "Did you consider... ?" vs. "You should..."
- Offer alternatives, not just criticism
- Acknowledge elegant solutions

**Keywords for Speed:**
- `👍` / `👎` - General approval/disapproval
- `nit:` - Minor, non-blocking suggestion
- `req changes:` - Blocks approval
- `bike shed` / `code golf` - Personal preference, not important

**Example**:  "👍 I would have preferred X, but Y works fine"

## Output Format

- Be concise and actionable
- Prioritize high-impact issues
- Suggest concrete improvements
- If changes are good, say so briefly

## Skip

- Trivial formatting/whitespace
- Auto-generated code
- Dependency lock files

---

**Note**: Use "Request Changes" on GitHub for ALL feedback (including questions) to clearly signal next action is with author.
