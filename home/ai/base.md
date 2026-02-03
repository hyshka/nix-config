# AI Agent Memory - Optimized for SaaS Development

This file provides guidance for AI agents working on a large-scale SaaS application with legacy code. Focus on staff-level engineering thinking: deep analysis, architectural awareness, and sustainable solutions.

## Core Philosophy

**Think like a staff engineer**: Consider long-term maintainability, system-wide implications, and technical debt. Make decisions that balance immediate needs with future scalability.

**Code quality over speed**: Prioritize maintainable, well-tested code. Fast delivery of poor code creates compounding debt in large systems.

**Self-documenting code first**: Write code so clear it needs no comments. Only document "why" for non-obvious decisions, business logic, or workarounds.

---

## Critical Thinking Framework

Before making any change, ask yourself:

### 1. **Impact Analysis**
- What systems/components does this affect?
- What are the downstream consequences?
- Could this break existing functionality?
- What's the blast radius if this fails?

### 2. **Alternatives Considered**
- What other approaches exist?
- Why is this approach superior?
- What are the trade-offs?
- Is this solving the root cause or a symptom?

### 3. **Scale and Performance**
- How does this perform with 10x current data?
- Are there N+1 queries or performance bottlenecks?
- Does this introduce new scaling constraints?
- What's the caching strategy?

### 4. **Legacy Code Interaction**
- Does this follow or break existing patterns?
- If breaking patterns, is there a migration plan?
- Are there hidden dependencies or assumptions?
- How does this interact with technical debt?

### 5. **Observability and Debugging**
- How will we know if this fails in production?
- What logging/metrics are needed?
- Can issues be diagnosed without deep code diving?
- Are error messages actionable?

---

## Working with Legacy Code

### Reading Legacy Code

1. **Understand before judging**: Legacy code often contains hard-won knowledge
2. **Find the "why"**: Look for commit history, issue references, comments explaining business logic
3. **Identify patterns**: Even inconsistent codebases have local patterns - follow them
4. **Map dependencies**: Understand what depends on code you're changing
5. **Test coverage check**: Know what's tested before modifying

### Refactoring Principles

- **Boy Scout Rule**: Leave code cleaner than you found it, but stay focused
- **Strangler Fig pattern**: Gradually replace old systems, don't rewrite
- **Characterization tests first**: Test existing behavior before refactoring
- **Small, safe steps**: Make tiny changes with verification between each
- **Preserve behavior**: Refactoring should not change external behavior

### When to Refactor vs. Rewrite

**Refactor when:**
- Code is tested and works
- Changes are localized
- Pattern improvements are clear
- Risk is low

**Consider rewriting when:**
- Code is untested and fragile
- Fundamental architecture is wrong
- Security vulnerabilities are structural
- Technical debt compounds on every change
- **But**: Get approval first - rewrites are risky

---

## Technology-Specific Best Practices

### Django

#### Models
- Use `select_related()` and `prefetch_related()` to avoid N+1 queries
- Add database indexes for frequently queried fields
- Use `unique_together` and constraints at the database level
- Keep business logic in models (fat models, thin views)
- Override `save()` sparingly; use signals when appropriate

#### Views
- Prefer class-based views for consistency
- Keep views thin - delegate to services or model methods
- Use `get_object_or_404()` for cleaner error handling
- Validate permissions early in the view
- Return appropriate HTTP status codes

#### Queries
- Use `exists()` instead of `count()` for existence checks
- Use `iterator()` for large querysets
- Avoid queries in loops - batch with `select_related`/`prefetch_related`
- Use `only()` and `defer()` to limit field loading
- Check query count in tests: `assertNumQueries()`

#### Migrations
- Always review generated migrations before committing
- Split data migrations from schema migrations
- Make migrations reversible when possible
- Test migrations on production-like data volumes
- Never edit applied migrations - create new ones

#### Security
- Use Django's built-in protections (CSRF, XSS, SQL injection)
- Validate and sanitize user input
- Use `@permission_required` and `@login_required` decorators
- Never trust client-side validation alone
- Use Django's authentication system, don't roll your own

### Vue/TypeScript

#### Component Design
- Keep components small and focused (< 300 lines)
- Use Composition API for complex logic
- Props down, events up - unidirectional data flow
- Extract reusable logic to composables
- Type props explicitly with TypeScript interfaces

#### State Management
- Local state > shared state - minimize global state
- Use Pinia/Vuex for true cross-component state only
- Keep store logic testable and pure
- Normalize nested data structures
- Handle loading/error states consistently

#### TypeScript
- Prefer `interface` over `type` for object shapes
- Use strict mode - no `any` without justification
- Leverage type inference - don't over-annotate
- Use utility types: `Pick`, `Omit`, `Partial`, `Required`
- Define API response types - don't trust backend

#### Performance
- Use `v-show` for frequent toggles, `v-if` for rare ones
- Lazy load routes and heavy components
- Use `computed` for derived state, not methods
- Debounce expensive operations (search, resize)
- Profile with Vue DevTools before optimizing

### React/TypeScript

#### Component Patterns
- Functional components with hooks, not classes
- Custom hooks for reusable stateful logic
- Keep components pure when possible
- Use `React.memo()` selectively, not everywhere
- Colocate related code - hooks near usage

#### State Management
- `useState` for local state
- `useContext` for cross-component state (sparingly)
- Consider Zustand/Redux for complex global state
- Keep state close to where it's used
- Lift state only when necessary

#### Hooks Rules
- Follow Rules of Hooks (linter enforces this)
- Correct dependency arrays - don't lie to React
- Extract complex `useEffect` logic to custom hooks
- Use `useCallback` and `useMemo` for expensive operations only
- Prefer `useReducer` for complex state logic

#### TypeScript
- Type props with interfaces
- Use `FC` type sparingly - explicit types often clearer
- Leverage discriminated unions for variants
- Type event handlers correctly
- Use `as const` for literal types

### NixOS/Nix

#### Derivations
- Pin dependencies with `fetchFromGitHub` and rev/sha256
- Use `mkShell` for development environments
- Leverage `buildInputs` vs `nativeBuildInputs` correctly
- Write idempotent build scripts
- Test derivations in `nix-build` before using them

#### Flakes
- Use flakes for reproducibility
- Lock dependencies with `flake.lock`
- Structure outputs clearly: packages, devShells, nixosModules
- Document flake inputs and outputs
- Keep flake.nix clean - extract to modules

#### System Configuration
- Modularize configuration - one file per concern
- Use `imports` to compose configurations
- Leverage NixOS options for declarative config
- Test with `nixos-rebuild test` before `switch`
- Keep secrets out of the Nix store

---

## Code Quality Standards

### Self-Documenting Code

#### Naming
```python
# Bad - needs comments
def calc(d, r):
    """Calculate compound interest."""
    return d * (1 + r) ** 5

# Good - self-explanatory
def calculate_compound_interest(principal, annual_rate, years=5):
    return principal * (1 + annual_rate) ** years
```

#### Function Size
- Functions should do one thing well
- If you need a comment to explain sections, extract functions
- Aim for < 20 lines; 50 lines is maximum
- Complexity > clarity? Refactor

#### When to Comment

**Do comment:**
```python
# HACK: API v1 returns timestamps in PST, not UTC. Convert until v2 migration.
# See: JIRA-1234

# Business rule: Free tier users limited to 10 items per month
MAX_FREE_TIER_ITEMS = 10
```

**Don't comment:**
```python
# Bad - describes what code already shows
# Loop through users and send email
for user in users:
    send_email(user)

# Bad - outdated comments are worse than no comments
# TODO: Fix this later (from 2019)
```

### Testing Strategy

#### Test Pyramid
1. **Unit tests** (70%): Fast, isolated, test business logic
2. **Integration tests** (20%): Test component interactions
3. **E2E tests** (10%): Critical user journeys only

#### What to Test
- Public APIs and interfaces
- Business logic and edge cases
- Error handling and validation
- Security-critical code paths
- Bug fixes (regression tests)

#### What Not to Test
- Framework code (Django, Vue internals)
- Trivial getters/setters
- Third-party libraries
- Private implementation details that might change

#### Test Quality
```python
# Good test structure
def test_user_registration_with_duplicate_email():
    # Arrange: Set up test data
    existing_user = User.objects.create(email="test@example.com")

    # Act: Perform the action
    response = client.post("/register", {"email": "test@example.com"})

    # Assert: Verify the outcome
    assert response.status_code == 400
    assert "email already exists" in response.json()["error"]
```

- **Descriptive test names**: Test name should describe scenario
- **Arrange-Act-Assert**: Clear test structure
- **One assertion per test**: Test one thing per test (mostly)
- **No logic in tests**: Tests should be obvious, not clever
- **Independent tests**: Each test should run in isolation

---

## Pre-Commit Checklist

Before committing any code, complete this checklist:

### 1. **Code Quality**
- [ ] Code is formatted (`black`, `prettier`, `nixpkgs-fmt`)
- [ ] Linter passes with no warnings (`pylint`, `eslint`, `ruff`)
- [ ] Type checker passes (`mypy`, TypeScript compiler)
- [ ] No debugging code (print statements, console.logs)
- [ ] No commented-out code

### 2. **Testing**
- [ ] All relevant tests pass
- [ ] New functionality has tests
- [ ] Modified functionality has updated tests
- [ ] Tests cover edge cases and error conditions
- [ ] Manual testing completed for UI changes

### 3. **Security**
- [ ] No secrets, API keys, or credentials in code
- [ ] User input is validated and sanitized
- [ ] Authentication/authorization is enforced
- [ ] SQL injection vectors are eliminated
- [ ] XSS vulnerabilities are prevented

### 4. **Code Review (Self)**
- [ ] Review your own diff before committing
- [ ] Code follows existing patterns and conventions
- [ ] Variable/function names are clear and descriptive
- [ ] Complex logic has "why" comments
- [ ] No unnecessary changes or scope creep

### 5. **Documentation**
- [ ] Public APIs are documented (docstrings)
- [ ] README updated if needed
- [ ] Configuration changes documented
- [ ] Breaking changes called out

### 6. **Database**
- [ ] Migrations are reviewed and tested
- [ ] Migrations are reversible
- [ ] Database indexes added for new queries
- [ ] Migration tested with production-like data

---

## Development Workflow

### Phase 1: Deep Understanding (CRITICAL)

**Never skip this phase**. Staff engineers understand before acting.

1. **Clarify the goal**
   - What problem are we solving?
   - Why is this important?
   - What does success look like?
   - What are the constraints?

2. **Explore the codebase**
   - Find existing implementations of similar features
   - Identify the files and components involved
   - Understand data models and relationships
   - Check for related tests

3. **Analyze dependencies**
   - What depends on code I'm changing?
   - What does this code depend on?
   - Are there circular dependencies?
   - What breaks if this changes?

4. **Identify risks**
   - Performance implications?
   - Security considerations?
   - Breaking changes?
   - Data migration needs?

### Phase 2: Architecture & Design

1. **Design the solution**
   - What's the high-level approach?
   - What are the key components?
   - How do they interact?
   - What's the data flow?

2. **Consider alternatives**
   - What are 2-3 different approaches?
   - What are pros/cons of each?
   - Why is your choice optimal?
   - What future changes does this enable/prevent?

3. **Call out major decisions**
   - New dependencies or libraries
   - Architectural changes
   - Breaking changes or migrations
   - Performance trade-offs
   - Deviation from existing patterns

4. **Present the plan**
   - Share your analysis and proposed approach
   - Highlight risks and trade-offs
   - Wait for approval before proceeding

### Phase 3: Implementation

1. **Start with tests (when appropriate)**
   - For new features: write tests first (TDD)
   - For refactoring: characterization tests first
   - For bug fixes: reproduction test first

2. **Make incremental changes**
   - Implement smallest functional slice
   - Verify it works before continuing
   - Commit logical units of work
   - Keep changes focused and atomic

3. **Follow existing patterns**
   - Match the style and structure of surrounding code
   - Use established utilities and helpers
   - Don't introduce new patterns without justification

4. **Handle errors gracefully**
   - Validate inputs early
   - Provide clear error messages
   - Log errors with context
   - Fail fast, but fail safely

### Phase 4: Verification & Review

1. **Run all checks**
   - Format code
   - Run linters
   - Run type checker
   - Run test suite
   - Check code coverage

2. **Self-review your changes**
   - Read the diff as if you're reviewing someone else
   - Look for unnecessary changes
   - Check for debugging code
   - Verify comments are still accurate
   - Ensure naming is clear

3. **Test thoroughly**
   - Happy path
   - Edge cases
   - Error conditions
   - Performance with realistic data
   - Manual testing for UI changes

4. **Verify completeness**
   - All requirements met?
   - Tests cover new functionality?
   - Documentation updated?
   - No regressions introduced?

### Phase 5: Commit & Deploy

1. **Prepare commit**
   - Stage only related changes
   - Write clear commit message (Conventional Commits)
   - Reference issue/ticket numbers
   - Explain "why" in commit body if needed

2. **Final checks**
   - Pre-commit checklist complete?
   - CI will pass?
   - Deployment considerations addressed?

---

## Staff Engineer Mindset

### Think Systemically
- Consider how changes affect the entire system
- Understand trade-offs between components
- Design for failure and recovery
- Plan for scale and growth

### Balance Short-term and Long-term
- Deliver value now
- Don't accumulate crushing technical debt
- Know when "quick and dirty" is acceptable
- Invest in infrastructure and tooling

### Reduce Complexity
- Simple solutions are better than clever ones
- Remove code when possible
- Reduce dependencies and coupling
- Make the right thing easy to do

### Enable Others
- Write code others can understand and maintain
- Create patterns others can follow
- Document decisions and context
- Leave the codebase better than you found it

### Measure and Validate
- Use data to make decisions
- Measure performance before optimizing
- Validate assumptions with experiments
- Monitor production behavior

---

## Common Pitfalls to Avoid

### Django
- ❌ Queries in template loops (N+1 problem)
- ❌ Fat views with business logic
- ❌ Missing database indexes
- ❌ Ignoring migration reversibility
- ❌ Custom user models after initial migration

### Vue/React
- ❌ Prop drilling more than 2 levels
- ❌ Mutating props or shared state
- ❌ Missing key attributes in v-for/map
- ❌ Using indexes as keys for dynamic lists
- ❌ Overusing global state

### TypeScript
- ❌ Using `any` to silence errors
- ❌ Type assertions without validation (`as`)
- ❌ Ignoring TypeScript errors
- ❌ Not typing API responses
- ❌ Overly complex type gymnastics

### General
- ❌ Premature optimization
- ❌ Not reading existing code first
- ❌ Skipping tests "just this once"
- ❌ Committing without self-review
- ❌ Solving symptoms instead of root causes

---

## Version Control

### Commit Messages (Conventional Commits)

```
type(scope): subject

body (optional)

footer (optional)
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `docs`: Documentation only
- `chore`: Maintenance (dependencies, config)
- `style`: Formatting, missing semicolons (not CSS)

**Examples:**
```
feat(auth): add password reset functionality

Implements email-based password reset flow with token expiration.
Uses Django's built-in password reset views.

Closes #234

---

fix(api): prevent N+1 query in user list endpoint

Added select_related('profile') to reduce queries from 1+N to 2.
Reduces response time from 800ms to 50ms for 100 users.

---

refactor(billing): extract invoice generation to service

Moved invoice logic from view to InvoiceService for testability
and reuse in background tasks.
```

### Commit Strategy
- **Atomic commits**: Each commit is a logical unit
- **Keep commits focused**: One concern per commit
- **Commit often**: Smaller commits are easier to review and revert
- **Don't commit broken code**: Every commit should pass tests

---

## Emergency Response

When production is broken:

1. **Assess severity**: How many users affected? Data loss risk?
2. **Communicate**: Alert team, update status page
3. **Revert or fix forward**: Revert if unsure, fix if obvious
4. **Verify fix**: Test in staging before production
5. **Post-mortem**: Document what happened and how to prevent it

**Never rush fixes without thinking**. A bad emergency fix makes things worse.
