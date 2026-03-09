---
name: test-smell-detector
description: Detect test anti-patterns, code smells, and quality issues in existing test suites.
---

# Test Smell Detector

Analyze existing test suites for anti-patterns, flaky test indicators, maintainability issues, and missing best practices. Provides actionable refactoring suggestions with severity classification.

## Trigger Phrases

Use this skill when the user asks for tasks like:
- "Review my test quality"
- "Find test smells in this project"
- "Are my tests well-written?"
- "Detect flaky tests"
- "Find anti-patterns in test code"
- "Review test maintainability"
- "Why are my tests unreliable?"

## Use / Do Not Use

Use this skill for:
- Detecting test anti-patterns and code smells
- Identifying flaky test indicators
- Reviewing assertion quality and coverage
- Checking test isolation and independence
- Finding maintainability issues in test code

Do not use this skill for:
- Generating new tests (use `api-test-generator` or `e2e-test-generator`)
- Measuring code coverage metrics (use `test-coverage-analyzer`)
- Analyzing production code quality (this is test-specific)

## Local Files In This Skill

- References:
  - `references/test-smell-catalog.md`
  - `references/flaky-test-patterns.md`
  - `references/refactoring-guide.md`

## Deterministic Execution Flow (Required)

### 1. Discovery — Find Test Files

```bash
find . -maxdepth 5 -type f \( \
  -name "test_*.py" -o -name "*_test.py" -o \
  -name "*.test.js" -o -name "*.test.ts" -o \
  -name "*.spec.js" -o -name "*.spec.ts" -o \
  -name "*Test.java" -o -name "*_test.go" -o \
  -name "*.test.jsx" -o -name "*.test.tsx" -o \
  -name "*.spec.jsx" -o -name "*.spec.tsx" \
\) | head -50
```

Determine:
- Test framework (pytest, jest, vitest, JUnit, go test, etc.)
- Number of test files and approximate test count
- Test directory structure

If user specifies a file or directory, scope analysis to that target.

### 2. Analyze for Test Smells

Read test files and check for each smell category:

**Category 1: Assertion Smells**
- `no-assertion` — Test has no assert/expect/should statement
- `redundant-assertion` — Asserting a constant (assert True, expect(true).toBe(true))
- `weak-assertion` — Only checking status code, not response body
- `boolean-trap` — `assert result` instead of specific value check
- `magic-number` — Hardcoded values without context in assertions

**Category 2: Structure Smells**
- `eager-test` — Single test doing too many things (multiple unrelated assertions)
- `mystery-guest` — Test depends on external state (file, DB, env var) without setup
- `general-fixture` — Shared fixture that most tests don't fully need
- `test-maverick` — Test that modifies shared state and breaks other tests
- `conditional-logic` — if/else, loops, or try/catch inside test body

**Category 3: Maintainability Smells**
- `hardcoded-values` — URLs, IDs, emails etc. hardcoded instead of fixtures/factories
- `duplicate-test` — Near-identical tests that should be parameterized
- `dead-test` — Skipped/disabled tests with no explanation
- `obscure-test` — Test name doesn't describe what it verifies
- `long-test` — Test body exceeds 30 lines of logic

**Category 4: Reliability Smells (Flaky Indicators)**
- `sleep-wait` — Uses sleep() or fixed timeout instead of explicit wait
- `order-dependent` — Test relies on execution order
- `time-sensitive` — Uses real clock/dates without mocking
- `network-dependent` — Calls external services without mock/stub
- `race-condition` — Concurrent operations without synchronization

**Category 5: Isolation Smells**
- `shared-mutable-state` — Tests share mutable variables
- `missing-cleanup` — Resources created but never cleaned up
- `database-leak` — Test creates DB records without rollback/cleanup
- `global-side-effect` — Test modifies global config, env vars, or singletons

### 3. Detection Commands

```bash
# Find tests without assertions (Python)
grep -rn "def test_" --include="*.py" -l | xargs grep -L "assert\|pytest.raises\|pytest.warns"

# Find sleep in tests
grep -rn "sleep\|setTimeout\|Thread.sleep\|time.sleep" --include="*.py" --include="*.js" --include="*.ts" --include="*.java" tests/ test/ spec/ __tests__/ 2>/dev/null

# Find skipped tests
grep -rn "@pytest.mark.skip\|@Disabled\|xit(\|xdescribe(\|test.skip\|\.skip(" --include="*.py" --include="*.js" --include="*.ts" --include="*.java" tests/ test/ spec/ __tests__/ 2>/dev/null

# Find hardcoded URLs/IDs
grep -rn "http://\|https://\|localhost:" --include="*.py" --include="*.js" --include="*.ts" tests/ test/ spec/ __tests__/ 2>/dev/null | grep -v "conftest\|fixture\|config\|setup\|env"

# Find conditional logic in tests
grep -rn "^\s*if \|^\s*for \|^\s*while \|^\s*try:" --include="*.py" tests/ test/ 2>/dev/null
grep -rn "^\s*if (\|^\s*for (\|^\s*while (\|^\s*try {" --include="*.js" --include="*.ts" tests/ test/ spec/ __tests__/ 2>/dev/null
```

### 4. Load References (Only as Needed)

| Finding category | Read this file |
|---|---|
| Any smell detected | `references/test-smell-catalog.md` (for the specific section) |
| Flaky test indicators found | `references/flaky-test-patterns.md` |
| Refactoring needed | `references/refactoring-guide.md` |

### 5. Classify Findings by Severity

- **Critical** — Tests that give false confidence: no assertions, redundant assertions, tests that can never fail
- **High** — Flaky indicators: sleep waits, order dependency, network calls without mocks
- **Medium** — Maintainability: hardcoded values, duplicate tests, overly long tests
- **Low** — Style: naming conventions, minor structural improvements

### 6. No-Issue Fast Path (Required)

If no test smells are detected:
- Return a concise pass summary with test stats
- Do NOT open reference files
- Do NOT suggest unnecessary refactoring

### 7. Produce Standard Report

```markdown
## Test Smell Detection Report

- **Target**: <path>
- **Test files analyzed**: <count>
- **Test cases analyzed**: <approx count>
- **Framework**: <detected framework>
- **Overall health**: CLEAN | NEEDS ATTENTION | PROBLEMATIC

### Critical
- <finding with file:line or `None`>

### High
- <finding with file:line or `None`>

### Medium
- <finding with file:line or `None`>

### Low
- <finding with file:line or `None`>

### Summary by Category
| Category | Issues found |
|---|---|
| Assertion smells | <count> |
| Structure smells | <count> |
| Maintainability smells | <count> |
| Reliability smells | <count> |
| Isolation smells | <count> |

### Recommended Refactoring
- <specific refactoring per finding, grouped by priority>

### References Used
- <list only files actually read>
```

### 8. Offer Fix Application

After reporting:
- Ask whether to apply refactoring fixes
- If user approves, fix in batches by category (critical first)
- Rerun detection after each batch

## Fallback Behavior (Explicit)

### Fallback A: No Test Files Found

Action: Report that no test files were found. Suggest using `api-test-generator` or `e2e-test-generator` to create tests first.

### Fallback B: Unsupported Test Framework

Action: Perform language-agnostic analysis (assertion presence, sleep calls, hardcoded values). Note reduced detection coverage.

## Done Criteria

- Test files discovered and scoped.
- All 5 smell categories checked.
- Findings classified by severity.
- Fast path used when no issues found.
- Specific refactoring suggestions provided per finding.
- Report follows standard template.

## Resources

- Smell catalog: `references/test-smell-catalog.md`
- Flaky patterns: `references/flaky-test-patterns.md`
- Refactoring guide: `references/refactoring-guide.md`

## Source Links

- [Test Smells - testsmells.org](https://testsmells.org/)
- [xUnit Test Patterns](http://xunitpatterns.com/)
- [Google Testing Blog — Flaky Tests](https://testing.googleblog.com/)
