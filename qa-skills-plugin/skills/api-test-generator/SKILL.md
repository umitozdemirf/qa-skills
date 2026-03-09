---
name: api-test-generator
description: Generate API test suites using native unit test frameworks (pytest, vitest/jest, JUnit, go test) directly — no intermediate tools.
---

# API Test Generator

Generate production-ready API test suites using the project's native unit test framework directly. No intermediate tools like Postman, Karate, or SoapUI — tests are written as first-class code using pytest+httpx, vitest+supertest, JUnit+REST-assured, or go test.

## Trigger Phrases

Use this skill when the user asks for tasks like:
- "Generate API tests for this endpoint"
- "Create a test suite for my REST API"
- "Write integration tests for this service"
- "Create pytest tests for these endpoints"
- "Test this GraphQL API"
- "Generate API tests from OpenAPI/Swagger spec"
- "Write vitest API tests for this Express app"

## Use / Do Not Use

Use this skill for:
- Generating API test files using native test frameworks (pytest, vitest, jest, JUnit, go test)
- Creating assertion-rich test cases covering happy path, error cases, and edge cases
- Scaffolding authentication flows in tests (OAuth2, API key, JWT, Basic)
- Generating data-driven / parameterized API tests
- Creating contract validation tests from schemas

Do not use this skill for:
- Validating existing test quality (use `test-smell-detector`)
- Security-specific testing like SQLi/XSS (use `security-test-generator`)
- Performance/load testing (out of scope for this skill pack today; use a dedicated performance workflow/tool)
- UI/browser E2E testing (use `e2e-test-generator`)
- Generating Postman collections, Karate features, or SoapUI projects (use native test code instead)

## Local Files In This Skill

- References:
  - `references/http-status-assertions.md`
  - `references/auth-patterns.md`
  - `references/test-structure-guide.md`
- Templates:
  - `assets/templates/pytest-api/`
  - `assets/templates/vitest-api/`
- Examples: `examples/`

## Deterministic Execution Flow (Required)

Run these steps in order. Do not skip steps unless a documented fallback branch applies.

### 1. Discovery — Understand the API Surface

Determine API source from one of:

**Option A: OpenAPI/Swagger Spec Exists**

```bash
# Find spec files
find . -maxdepth 3 -name "openapi.*" -o -name "swagger.*" -o -name "api-spec.*" | head -10
```

Read the spec and extract:
- Base URL and servers
- All endpoints (method + path)
- Request/response schemas
- Authentication schemes
- Required vs optional parameters

**Option B: Source Code Analysis**

```bash
# Detect framework
grep -rl "FastAPI\|flask\|express\|Spring\|gin\|Echo\|Fiber\|NestJS\|Rails\|Django" --include="*.py" --include="*.js" --include="*.ts" --include="*.java" --include="*.go" --include="*.rb" . | head -20
```

Extract endpoints from route definitions:
- Route decorators/annotations
- Request/response models
- Middleware (auth, validation)
- Path and query parameters

**Option C: User-Provided Endpoint List**

If user provides endpoints directly, parse them and confirm before generating.

### 2. Analyze Existing Test State

```bash
# Check for existing test files
find . -maxdepth 4 -type f \( -name "test_*.py" -o -name "*.test.js" -o -name "*.test.ts" -o -name "*Test.java" -o -name "*_test.go" -o -name "*.spec.ts" -o -name "*.spec.js" \) | head -30
```

```bash
# Check for test config
find . -maxdepth 2 -name "pytest.ini" -o -name "pyproject.toml" -o -name "jest.config.*" -o -name "vitest.config.*" -o -name "pom.xml" -o -name "build.gradle" | head -10
```

If tests exist, read a sample to match the project's style:
- Naming conventions
- Fixture patterns
- Assertion library
- Base URL configuration

### 3. Select Test Framework

Always use the project's native test framework. No intermediate tools.

| Project language | Default framework | HTTP client |
|---|---|---|
| Python (FastAPI/Flask/Django) | **pytest** | httpx (async) or requests |
| JavaScript/TypeScript (Express/NestJS) | **vitest** or jest | supertest or fetch |
| Java (Spring) | **JUnit 5** | REST-assured or WebTestClient |
| Go (Gin/Echo/Fiber) | **go test** | net/http/httptest |
| Kotlin (Ktor/Spring) | **JUnit 5** | REST-assured or ktor-client |

If the project already has tests, match the existing framework and style. User can override.

### 4. Load References (Only as Needed)

Only read references matching the generation needs:

| Need | Read this file |
|---|---|
| Status code assertion patterns | `references/http-status-assertions.md` |
| Auth test setup (OAuth2, JWT, API key) | `references/auth-patterns.md` |
| Test file structure and organization | `references/test-structure-guide.md` |

### 5. Generate Test Suite

For each endpoint, generate tests covering:

**Required test categories (always generate):**

1. **Happy path** — Valid request with expected 2xx response
2. **Input validation** — Missing required fields, wrong types, empty strings
3. **Authentication** — Unauthenticated (401), insufficient permissions (403)
4. **Not found** — Invalid resource IDs (404)
5. **Response schema validation** — Verify response structure matches spec/model

**Conditional test categories (generate when applicable):**

6. **Pagination** — If endpoint supports pagination params
7. **Filtering/sorting** — If query params exist
8. **Idempotency** — For PUT/DELETE operations
9. **Rate limiting** — If rate limit headers are documented
10. **Content negotiation** — If multiple content types are supported

**Test structure rules:**
- One test file per resource/domain (not per endpoint)
- Use fixtures/factories for test data — no hardcoded magic values
- Each test must have a clear assertion — no "smoke only" tests
- Use descriptive test names: `test_<action>_<condition>_<expected_result>`
- Include setup/teardown for data-dependent tests
- Add docstrings for non-obvious test scenarios

### 6. Generate Supporting Files

Based on framework:

- **conftest.py / setup files** — Base URL config, auth fixtures, common helpers
- **test data factories** — Faker/factory-based data generation
- **environment config** — .env.test or similar for base URLs and credentials placeholders
- **requirements/dependencies** — List packages needed to run tests

### 7. Output Summary Report

```markdown
## API Test Generation Report

- **Source**: <OpenAPI spec | source code | user-provided>
- **Framework**: <pytest | jest | JUnit | etc.>
- **Endpoints covered**: <count>
- **Test files generated**: <count>
- **Total test cases**: <count>

### Generated Files
| File | Endpoints | Test count |
|---|---|---|
| <file> | <endpoints> | <count> |

### Test Categories Coverage
| Category | Count |
|---|---|
| Happy path | <n> |
| Input validation | <n> |
| Auth | <n> |
| Not found | <n> |
| Schema validation | <n> |

### How to Run
\`\`\`bash
<exact command to run tests>
\`\`\`

### Dependencies to Install
\`\`\`bash
<install command>
\`\`\`
```

## Fallback Behavior (Explicit)

### Fallback A: No OpenAPI Spec and No Readable Source Code

Condition: Cannot determine endpoints from spec or code.

Action:
1. Ask user to provide endpoint list in format: `METHOD /path — description`
2. Generate tests based on user input
3. Mark response schema tests as `TODO` since no schema is available

### Fallback B: Unknown or Unsupported Framework

Condition: Language/framework not in the supported table.

Action:
1. Default to **pytest + httpx** (most portable, works against any HTTP API)
2. If Python is unavailable, generate a **shell script with cURL commands** as minimal fallback
3. Note that the user can request a specific framework override

### Fallback C: Partial API Surface

Condition: Only some endpoints are discoverable.

Action:
1. Generate tests for discovered endpoints
2. List undiscovered/ambiguous routes
3. Ask user to confirm or provide missing endpoints

## Progressive Disclosure Rules

- Always discover API surface first — do not generate blind tests.
- Do not read reference files unless the test generation requires specific patterns (auth, complex assertions).
- Generate supporting files only when they add value (skip conftest if only 1 test file).

## Done Criteria

Consider this skill execution complete only when:

- API surface was discovered and confirmed (endpoints, methods, schemas).
- Test framework was selected (auto-detected or user-chosen).
- Tests cover all required categories per endpoint.
- Supporting files (fixtures, config, dependencies) are generated.
- Summary report with run instructions is provided.
- User is asked whether to write files or review first.

## Resources

- HTTP status assertions: `references/http-status-assertions.md`
- Auth test patterns: `references/auth-patterns.md`
- Test structure guide: `references/test-structure-guide.md`
- Templates: `assets/templates/`
- Examples: `examples/`

## Source Links

- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)
- [pytest Documentation](https://docs.pytest.org/)
- [httpx Async Client](https://www.python-httpx.org/)
- [REST-assured](https://rest-assured.io/)
- [supertest](https://github.com/ladjs/supertest)
- [vitest](https://vitest.dev/)
