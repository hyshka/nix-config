---
description: Review uncommitted changes in git working directory
agent: plan
model: github-copilot/claude-sonnet-4.5
---

Review the uncommitted changes in the git working directory and provide actionable feedback.

## Context

!`git --no-pager diff`

## Review Focus

Evaluate the changes for:

1. **Code Quality**
   - Logic errors or bugs
   - Edge cases not handled
   - Performance concerns

2. **Maintainability**
   - Readability and clarity
   - Naming conventions
   - Code duplication

3. **Best Practices**
   - Language/framework conventions
   - Security vulnerabilities
   - Error handling

4. **Testing**
   - Missing test coverage
   - Test quality concerns

## Output Format

- Be concise and specific
- Reference exact code locations when possible
- Prioritize high-impact issues
- Suggest concrete improvements, not just problems
- If changes look good, say so briefly

## Exclusions

- Skip trivial style issues (formatting, whitespace)
- Don't review auto-generated code
- Ignore dependency lock files
