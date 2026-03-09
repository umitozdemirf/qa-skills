# Risk Scoring Model

## Overview

The risk scoring model evaluates code changes on 7 weighted dimensions to produce a composite risk score (1.0 - 5.0).

## Dimensions

### 1. Change Size (Weight: 15%)

| Score | Criteria |
|---|---|
| 5 | 500+ lines changed, 20+ files |
| 4 | 200-499 lines, 10-19 files |
| 3 | 50-199 lines, 5-9 files |
| 2 | 10-49 lines, 2-4 files |
| 1 | < 10 lines, 1 file |

### 2. Change Type (Weight: 20%)

| Score | Type |
|---|---|
| 5 | Database schema migration, API contract breaking change |
| 4 | New feature with business logic, auth/security changes |
| 3 | Bug fix in core logic, new API endpoint |
| 2 | Configuration change, dependency update |
| 1 | Documentation, comments, formatting |

### 3. Blast Radius (Weight: 20%)

| Score | Criteria |
|---|---|
| 5 | Shared library/core module used by 10+ services |
| 4 | Module used by 5-9 other modules |
| 3 | Module used by 2-4 other modules |
| 2 | Module used by 1 other module |
| 1 | Isolated module, no dependents |

### 4. Complexity (Weight: 15%)

| Score | Criteria |
|---|---|
| 5 | Cyclomatic complexity > 20, deep nesting, concurrent logic |
| 4 | Complexity 11-20, multi-step algorithms |
| 3 | Complexity 6-10, moderate branching |
| 2 | Complexity 2-5, simple conditionals |
| 1 | Linear flow, no branching |

Proxy when cyclomatic complexity tool is unavailable:
- Count `if/else/elif/switch/case/for/while/try/catch` in changed code
- Count nesting depth (> 3 levels = high)

### 5. Churn Rate (Weight: 10%)

| Score | Criteria |
|---|---|
| 5 | Changed 15+ times in last 90 days |
| 4 | Changed 10-14 times |
| 3 | Changed 5-9 times |
| 2 | Changed 2-4 times |
| 1 | Changed 0-1 times (stable) |

High churn + high complexity = strong defect predictor.

### 6. Test Coverage (Weight: 10%)

| Score | Criteria |
|---|---|
| 5 | No test file exists for changed module |
| 4 | Test file exists but < 30% function coverage |
| 3 | Moderate coverage (30-60%) |
| 2 | Good coverage (60-80%) |
| 1 | High coverage (> 80%) with quality assertions |

### 7. Criticality (Weight: 10%)

| Score | Domain |
|---|---|
| 5 | Authentication, authorization, payment processing, data encryption |
| 4 | User data handling, core business logic, external API integration |
| 3 | Search, reporting, notifications |
| 2 | UI components, formatting, logging |
| 1 | Internal tooling, documentation, dev scripts |

## Composite Score Calculation

```
risk_score = (change_size * 0.15) +
             (change_type * 0.20) +
             (blast_radius * 0.20) +
             (complexity * 0.15) +
             (churn_rate * 0.10) +
             (test_coverage * 0.10) +
             (criticality * 0.10)
```

## Risk Levels

| Score | Level | Color | Action |
|---|---|---|---|
| 4.0 - 5.0 | Critical | Red | Block merge without thorough testing and senior review |
| 3.0 - 3.9 | High | Orange | Require dedicated test cases and code review |
| 2.0 - 2.9 | Medium | Yellow | Standard testing, automated checks sufficient |
| 1.0 - 1.9 | Low | Green | Smoke test, auto-merge eligible |

## Confidence Modifiers

When data is incomplete, note reduced confidence:

| Missing data | Confidence reduction |
|---|---|
| No git history (churn unknown) | -15% |
| No coverage data | -10% |
| No dependency graph | -10% |
| Unknown domain criticality | -5% |
