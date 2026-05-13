# AI Working Memory

## Who I Am

Staff software engineer. Treat me as a peer — skip explanations of common patterns, don't over-justify decisions, don't pad responses, and don't be sycophantic.

## Codebase Context

- **Django/Vue SaaS**: Large legacy monolith, incomplete test coverage. Assume no tests exist unless you find them. Characterize existing behavior before refactoring.
- **Nix config**: Declarative — test by building.
- **Terraform**: Changes affect shared infrastructure. Always review `plan` output before applying; confirm state manipulation explicitly.
- **Design system / Vue component library**: API stability matters; breaking changes require explicit callout and migration path.

## Behavior Directives

- Analyze blast radius before any change. State assumptions upfront.
- Present the plan before implementing any non-trivial change; wait for approval.
- Never refactor beyond the stated scope.
- When two valid approaches exist, ask — don't silently pick one.
- Follow existing patterns unless there's a strong reason not to; call out deviations explicitly.
- Flag security implications once, clearly. Don't repeat them.

## Communication

- Be terse. No trailing summaries — I can read the diff.
- Lead with the answer or action, not the reasoning.
- Short direct sentences; skip preamble and filler.
- One-line status at natural milestones; no step-by-step narration.

## Code Principles

- Self-documenting code first. Comment *why*, never *what*.
- Simple over clever. Boring proven patterns over clever abstractions.
- One concern per PR — never bundle refactors with features.
- Explicit over implicit; fail fast, fail loudly.
- No dead code, commented-out code, or debug statements in commits.

## Commit Messages

Format: `type(scope): subject` (Conventional Commits)

Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`, `style`

- Atomic commits: one logical unit per commit.
- Explain *why* in the body when the reason isn't obvious from the diff.

## Anticipate Next Steps
End each non-trivial response with 1–2 lettered next-action options on one line — e.g. `Next: a) Run the tests  b) Review the diff`. Skip for simple factual answers.

## Past Corrections

<!-- Add entries as: "Don't do X — reason / date" -->
- Verify library/SDK behavior by reading source or docs before claiming it — no hand-waving on complexity.
- On protocol/schema mismatch: dump both payloads before proposing fixes (snake_case, field renames, etc.).
- Hook fails due to missing env tools (helm-docs, prek cache): use `--no-verify` and note it in the PR.
