# Coverage Metrics Guide

## Metric Types

### Line Coverage
Percentage of executable lines reached during tests. Most basic metric.

- **80%+ is good** for most projects
- Does not guarantee logic correctness — a line can execute without proper assertion

### Branch Coverage
Percentage of decision branches (if/else, switch, ternary) that are exercised.

- **70%+ is good** — more meaningful than line coverage
- Catches untested conditional paths

### Function/Method Coverage
Percentage of functions that are called at least once.

- Useful for identifying completely untested code units
- High function coverage with low branch coverage = shallow tests

### Path Coverage
Percentage of all possible execution paths tested. Exponential growth with conditions.

- Impractical to achieve 100%
- Focus on critical paths and edge cases

### Statement Coverage
Similar to line coverage but counts individual statements (multiple on one line).

## What Coverage Does NOT Tell You

1. **Assertion quality** — Code runs but nothing is verified
2. **Edge case coverage** — Happy path may hit 100% lines but miss boundary cases
3. **Integration correctness** — Unit coverage says nothing about component interaction
4. **Missing features** — Coverage can't detect untested requirements, only untested code
5. **Error handling quality** — Catch blocks may be reached but not properly handled

## Coverage Targets by Context

| Context | Target | Reasoning |
|---|---|---|
| Critical business logic | 90%+ | Payments, auth, data integrity |
| API endpoints | 80%+ | Every endpoint should have at least happy path + error tests |
| Utility/helper functions | 70%+ | Lower risk, but still useful |
| UI components | 60%+ | E2E tests complement unit coverage |
| Configuration/glue code | 50%+ | Low logic density |
| Generated code | Skip | Auto-generated, test the generator instead |

## Tools by Language

| Language | Tool | Report format |
|---|---|---|
| Python | coverage.py / pytest-cov | HTML, XML, JSON, LCOV |
| JavaScript/TypeScript | istanbul/nyc / c8 / vitest --coverage | HTML, LCOV, JSON |
| Java | JaCoCo | HTML, XML, CSV |
| Go | go test -cover | Text, HTML |
| C# | coverlet / dotCover | XML, JSON |

## Running Coverage

### Python
```bash
pytest --cov=src --cov-report=html --cov-report=xml --cov-report=term-missing
```

### JavaScript (vitest)
```bash
npx vitest --coverage
```

### Go
```bash
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## Interpreting Gaps

When coverage is low, classify gaps:

| Gap type | Action |
|---|---|
| Untested file | Create test file — high priority if the file has business logic |
| Untested function | Add test — prioritize by usage and risk |
| Untested branch | Add parameterized tests for each branch |
| Untested error path | Add negative tests (invalid input, mock failures) |
| Dead code | Remove if confirmed unused |
