---
name: test-plan-generator
description: Generate structured test plans with risk-based prioritization for features, PRs, or releases.
---

# Test Plan Generator

Generate comprehensive, risk-prioritized test plans for features, pull requests, sprints, or releases. Outputs structured plans with test cases, acceptance criteria, and execution order.

## Trigger Phrases

Use this skill when the user asks for tasks like:
- "Create a test plan for this feature"
- "Generate test cases for this PR"
- "What should I test for this release?"
- "Write a QA plan for this user story"
- "Create a regression test checklist"
- "Plan testing for this sprint"

## Use / Do Not Use

Use this skill for:
- Structured test plan creation from requirements, user stories, or code changes
- Risk-based test prioritization
- Acceptance criteria generation
- Regression checklist creation
- Test estimation and scoping

Do not use this skill for:
- Writing actual test code (use `api-test-generator` or `e2e-test-generator`)
- Analyzing existing test quality (use `test-smell-detector`)
- Risk analysis of code without testing context (use `risk-analyzer`)

## Local Files In This Skill

- References:
  - `references/test-types-guide.md`
  - `references/risk-priority-matrix.md`
  - `references/test-plan-templates.md`

## Deterministic Execution Flow (Required)

### 1. Discovery — Understand the Scope

Determine the input source:

**Option A: PR / Code Diff**

```bash
# Get changed files
git diff --name-only HEAD~1..HEAD 2>/dev/null || git diff --name-only main...HEAD 2>/dev/null

# Get diff stats
git diff --stat HEAD~1..HEAD 2>/dev/null || git diff --stat main...HEAD 2>/dev/null
```

Read changed files to understand:
- What modules/features are affected
- What type of change (new feature, bug fix, refactor, config change)
- Which layers are touched (UI, API, DB, infra)

**Option B: User Story / Requirements**

Parse user-provided description for:
- Functional requirements
- Non-functional requirements (performance, security, accessibility)
- Acceptance criteria (if provided)
- Affected systems/modules

**Option C: Release / Sprint Scope**

Analyze multiple PRs or a changelog:

```bash
git log --oneline --since="2 weeks ago" | head -30
```

### 2. Risk Assessment

For each changed area, evaluate:

| Factor | Weight | Score (1-5) |
|---|---|---|
| User impact (how many users affected) | 25% | |
| Change complexity (lines changed, files touched) | 20% | |
| Historical defect rate (has this area broken before) | 20% | |
| Dependency count (how many systems depend on this) | 15% | |
| Test coverage (existing test coverage for this area) | 10% | |
| Reversibility (how easy to rollback) | 10% | |

Risk score = weighted sum. Categories:
- **Critical risk (4.0-5.0)**: Must test thoroughly, block release if untested
- **High risk (3.0-3.9)**: Needs dedicated test cases
- **Medium risk (2.0-2.9)**: Standard test coverage
- **Low risk (1.0-1.9)**: Smoke test sufficient

### 3. Generate Test Categories

For each affected area, determine applicable test types:

| Test type | When to include |
|---|---|
| Functional | Always |
| Integration | When multiple services/modules interact |
| API contract | When API endpoints change |
| UI/E2E | When user-facing UI changes |
| Security | When auth, input handling, or data access changes |
| Performance | When high-traffic paths or DB queries change |
| Accessibility | When UI components change |
| Compatibility | When frontend changes (cross-browser) |
| Data migration | When DB schema changes |
| Rollback | When deployment process changes |

### 4. Load References (Only as Needed)

| Need | Read this file |
|---|---|
| Test type definitions and when to apply | `references/test-types-guide.md` |
| Risk scoring methodology | `references/risk-priority-matrix.md` |
| Plan format templates | `references/test-plan-templates.md` |

### 5. Generate Test Plan

```markdown
## Test Plan: <Feature/PR/Release Name>

### Overview
- **Scope**: <what is being tested>
- **Type**: <feature | bugfix | refactor | release>
- **Risk level**: <Critical | High | Medium | Low>
- **Estimated effort**: <time estimate>
- **Target environment**: <staging | QA | pre-prod>

### Risk Assessment
| Area | Impact | Complexity | History | Dependencies | Coverage | Risk Score |
|---|---|---|---|---|---|---|
| <module> | <1-5> | <1-5> | <1-5> | <1-5> | <1-5> | <weighted> |

### Test Cases (Priority Order)

#### P0 — Must Pass (Release Blocker)
| ID | Test Case | Type | Steps | Expected Result | Status |
|---|---|---|---|---|---|
| TC-001 | <name> | <functional/integration/...> | <steps> | <expected> | TODO |

#### P1 — Should Pass (High Priority)
| ID | Test Case | Type | Steps | Expected Result | Status |
|---|---|---|---|---|---|

#### P2 — Nice to Have (Medium Priority)
| ID | Test Case | Type | Steps | Expected Result | Status |
|---|---|---|---|---|---|

### Acceptance Criteria
- [ ] All P0 test cases pass
- [ ] All P1 test cases pass or have documented exceptions
- [ ] No critical or high severity bugs remain open
- [ ] <additional criteria based on scope>

### Regression Areas
- <areas not directly changed but potentially affected>
- <suggested regression test suites to run>

### Environment Requirements
- <required services, data, configurations>
- <test account/credentials needed>
- <feature flags to enable/disable>

### Out of Scope
- <explicitly excluded areas>
- <deferred testing items>

### Dependencies and Blockers
- <items that must be resolved before testing>
```

### 6. Provide Automation Mapping

For each test case, indicate:
- **Automatable**: Yes / No / Partial
- **Existing automation**: Link to existing test if available
- **Recommended tool**: Which generator skill to use (api-test-generator, e2e-test-generator, etc.)

## Fallback Behavior (Explicit)

### Fallback A: Insufficient Context

Condition: Cannot determine scope from code or user input.

Action:
1. Ask clarifying questions about scope, affected modules, and risk areas
2. Generate a template plan with placeholders
3. Mark areas needing user input as `[NEEDS INPUT]`

### Fallback B: No Git History Available

Condition: No git repo or no commit history.

Action:
1. Work from user-provided requirements only
2. Skip historical defect rate in risk assessment
3. Note reduced risk accuracy

## Done Criteria

- Scope clearly defined and confirmed.
- Risk assessment completed with scoring per area.
- Test cases generated with priority levels (P0/P1/P2).
- Acceptance criteria defined.
- Regression areas identified.
- Automation mapping provided.
- Plan follows standard template.

## Resources

- Test types guide: `references/test-types-guide.md`
- Risk matrix: `references/risk-priority-matrix.md`
- Plan templates: `references/test-plan-templates.md`

## Source Links

- [ISTQB Test Planning](https://www.istqb.org/)
- [Risk-Based Testing](https://www.satisfice.com/blog/archives/risk-based-testing)
- [Google Test Planning](https://testing.googleblog.com/)
