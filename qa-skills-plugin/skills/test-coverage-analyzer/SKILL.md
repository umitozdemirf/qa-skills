---
name: test-coverage-analyzer
description: Analyze test coverage gaps, identify untested code paths, and recommend missing test scenarios.
---

# Test Coverage Analyzer

Analyze test coverage beyond simple line/branch metrics. Identifies untested code paths, missing edge cases, and coverage gaps by comparing test suites against source code structure.

## Trigger Phrases

Use this skill when the user asks for tasks like:
- "Analyze my test coverage"
- "What code paths are untested?"
- "Find coverage gaps"
- "Which functions need more tests?"
- "Show me untested endpoints"
- "What's missing from my test suite?"
- "Coverage report for this module"

## Use / Do Not Use

Use this skill for:
- Identifying untested functions, methods, and classes
- Finding untested API endpoints
- Detecting missing edge case coverage
- Analyzing branch/path coverage gaps
- Mapping test-to-source relationships

Do not use this skill for:
- Generating test code (use `api-test-generator` or `e2e-test-generator`)
- Detecting test quality issues (use `test-smell-detector`)
- Running coverage tools that require build/execution (this skill analyzes statically)

## Local Files In This Skill

- References:
  - `references/coverage-metrics-guide.md`
  - `references/edge-case-catalog.md`
  - `references/coverage-tool-configs.md`

## Deterministic Execution Flow (Required)

### 1. Discovery — Map Source and Test Files

```bash
# Find source files (exclude tests, vendor, node_modules)
find . -maxdepth 5 -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.go" \) \
  ! -path "*/test*" ! -path "*/__test*" ! -path "*/spec/*" ! -path "*/node_modules/*" ! -path "*/vendor/*" ! -path "*/.venv/*" | head -50

# Find test files
find . -maxdepth 5 -type f \( \
  -name "test_*.py" -o -name "*_test.py" -o \
  -name "*.test.js" -o -name "*.test.ts" -o \
  -name "*.spec.js" -o -name "*.spec.ts" -o \
  -name "*Test.java" -o -name "*_test.go" \
\) | head -50
```

### 2. Check for Existing Coverage Reports

```bash
# Look for coverage output files
find . -maxdepth 3 -name "coverage.xml" -o -name "coverage.json" -o -name "lcov.info" -o -name "coverage.out" -o -name ".coverage" -o -name "htmlcov" -type d | head -10
```

If coverage report exists, parse it for baseline metrics. If not, perform static analysis.

### 3. Static Coverage Analysis

**Map source functions to tests:**

```bash
# Python: extract function/class definitions
grep -rn "^\s*def \|^\s*class \|^\s*async def " --include="*.py" src/ app/ 2>/dev/null | grep -v test | head -50

# Python: extract what tests reference
grep -rn "def test_" --include="*.py" tests/ test/ 2>/dev/null | head -50
```

```bash
# JavaScript/TypeScript: extract exports
grep -rn "export\s\+\(function\|class\|const\|default\)" --include="*.ts" --include="*.js" src/ 2>/dev/null | head -50

# JS/TS: extract test descriptions
grep -rn "it(\|test(\|describe(" --include="*.test.*" --include="*.spec.*" tests/ test/ __tests__/ src/ 2>/dev/null | head -50
```

**Map API routes to tests:**

```bash
# Find route definitions
grep -rn "@app\.\(get\|post\|put\|delete\|patch\)\|@router\.\|app\.\(get\|post\|put\|delete\|patch\)(" --include="*.py" --include="*.js" --include="*.ts" src/ app/ 2>/dev/null | head -30

# Find route references in tests
grep -rn "client\.\(get\|post\|put\|delete\|patch\)\|request\.\(get\|post\|put\|delete\|patch\)\|supertest" --include="*.py" --include="*.js" --include="*.ts" tests/ test/ __tests__/ 2>/dev/null | head -30
```

### 4. Identify Coverage Gaps

Categories of gaps:

**A. Untested source files** — Source files with no corresponding test file
**B. Untested functions** — Public functions/methods not referenced in any test
**C. Untested endpoints** — API routes with no corresponding test
**D. Missing error paths** — Functions with error handling but no error case tests
**E. Missing edge cases** — Based on parameter types and business logic

```bash
# Find error handling without corresponding test
grep -rn "except\|catch\|raise\|throw\|return.*error\|return.*404\|return.*500" --include="*.py" --include="*.js" --include="*.ts" src/ app/ 2>/dev/null | head -30
```

### 5. Load References (Only as Needed)

| Need | Read this file |
|---|---|
| Coverage metric explanations | `references/coverage-metrics-guide.md` |
| Common edge cases by data type | `references/edge-case-catalog.md` |
| Tool configuration help | `references/coverage-tool-configs.md` |

### 6. No-Issue Fast Path (Required)

If all source files have corresponding tests and no obvious gaps:
- Report coverage health as GOOD
- Do NOT open reference files
- Suggest running quantitative coverage tools for precise metrics

### 7. Produce Standard Report

```markdown
## Test Coverage Analysis Report

- **Target**: <path>
- **Source files**: <count>
- **Test files**: <count>
- **Test-to-source ratio**: <ratio>
- **Overall coverage health**: GOOD | GAPS FOUND | LOW COVERAGE

### Coverage Summary
| Metric | Value |
|---|---|
| Source files with tests | <n/total> (<percent>) |
| Public functions tested | <n/total> (<percent>) |
| API endpoints tested | <n/total> (<percent>) |
| Error paths tested | <n/total> (<percent>) |

### Untested Source Files (Critical Gaps)
| File | Functions | Risk |
|---|---|---|
| <file> | <function list> | <high/medium/low> |

### Untested Endpoints
| Method | Path | Source file |
|---|---|---|
| <GET/POST/...> | <path> | <file:line> |

### Missing Edge Case Tests
| Function | Missing scenario |
|---|---|
| <function> | <null input, empty array, boundary value, etc.> |

### Recommended Actions (Priority Order)
1. <highest priority gap + which generator skill to use>
2. <next priority>
3. ...

### How to Run Coverage Tools
\`\`\`bash
<command to generate quantitative coverage report>
\`\`\`
```

## Fallback Behavior (Explicit)

### Fallback A: No Test Files Found

Action: Report zero coverage. Recommend starting with `api-test-generator` for highest-risk source files.

### Fallback B: Non-Standard Project Structure

Action: Ask user to specify source and test directories. Perform analysis on provided paths.

### Fallback C: Compiled/Binary-Only Coverage Data

Action: Parse available coverage report (XML/JSON/LCOV) and focus on gap analysis from that data.

## Done Criteria

- Source and test files mapped.
- Coverage gaps identified across all categories (files, functions, endpoints, error paths, edge cases).
- Gaps prioritized by risk.
- Actionable recommendations provided with tool suggestions.
- Report follows standard template.

## Resources

- Coverage metrics: `references/coverage-metrics-guide.md`
- Edge case catalog: `references/edge-case-catalog.md`
- Tool configs: `references/coverage-tool-configs.md`

## Source Links

- [Coverage.py](https://coverage.readthedocs.io/)
- [Istanbul/nyc](https://istanbul.js.org/)
- [JaCoCo](https://www.jacoco.org/)
- [Go Cover](https://go.dev/blog/cover)
