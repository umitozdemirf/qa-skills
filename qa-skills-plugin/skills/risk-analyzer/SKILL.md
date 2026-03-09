---
name: risk-analyzer
description: Analyze code changes for risk impact, identify fragile areas, and recommend testing priorities.
---

# Risk Analyzer

Analyze code changes, modules, or entire codebases for risk factors. Produces risk scores, identifies fragile areas, maps change impact, and recommends test prioritization. Answers the question: "What could break?"

## Trigger Phrases

Use this skill when the user asks for tasks like:
- "What's the risk of this change?"
- "Analyze risk for this PR"
- "What could break if I merge this?"
- "Which areas are most fragile?"
- "Risk assessment for this release"
- "What should I test first?"
- "Impact analysis for this change"
- "Find high-risk modules"

## Use / Do Not Use

Use this skill for:
- Change impact analysis (which modules are affected by a change)
- Risk scoring for PRs, features, or releases
- Identifying high-risk/fragile areas in the codebase
- Test prioritization based on risk
- Regression risk mapping
- Dependency impact analysis

Do not use this skill for:
- Generating test plans (use `test-plan-generator` — it uses risk-analyzer's output)
- Security vulnerability scanning (use `security-test-generator`)
- Code quality analysis (this is risk-focused, not style-focused)
- Writing tests (use appropriate generator skills)

## Local Files In This Skill

- References:
  - `references/risk-scoring-model.md`
  - `references/change-impact-patterns.md`
  - `references/fragility-indicators.md`

## Deterministic Execution Flow (Required)

### 1. Discovery — Determine Analysis Scope

**Scope A: PR / Recent Changes**

```bash
# Changed files
git diff --name-only main...HEAD 2>/dev/null || git diff --name-only HEAD~1..HEAD

# Change stats
git diff --stat main...HEAD 2>/dev/null || git diff --stat HEAD~1..HEAD

# Commit messages for context
git log --oneline main...HEAD 2>/dev/null || git log --oneline -10
```

**Scope B: Specific Module**

```bash
# Module structure
find <module-path> -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.go" \) | head -30

# Module dependencies (imports)
grep -rn "^import \|^from \|require(\|import " --include="*.py" --include="*.js" --include="*.ts" <module-path> | head -30
```

**Scope C: Full Codebase**

```bash
# File count by directory
find . -maxdepth 2 -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.go" \) ! -path "*/node_modules/*" ! -path "*/.venv/*" | head -100
```

### 2. Change Impact Analysis

For each changed file, trace:

**Upstream dependencies (what this file depends on):**

```bash
# Find imports in changed files
grep -n "^import \|^from \|require(\|import {" <changed-file>
```

**Downstream dependents (what depends on this file):**

```bash
# Find files that import the changed module
MODULE_NAME=$(basename <changed-file> | sed 's/\.[^.]*$//')
grep -rl "$MODULE_NAME" --include="*.py" --include="*.js" --include="*.ts" --include="*.java" . 2>/dev/null | grep -v node_modules | grep -v __pycache__
```

**Blast radius calculation:**
- Direct dependents: files that import the changed file
- Transitive dependents: files that import direct dependents
- Depth: how many levels deep the dependency chain goes

### 3. Risk Factor Scoring

Score each changed area on these dimensions (1-5 scale):

| Factor | How to assess | Weight |
|---|---|---|
| **Change size** | Lines changed, files touched | 15% |
| **Change type** | Refactor (low) vs logic change (medium) vs schema/API change (high) | 20% |
| **Blast radius** | Number of downstream dependents | 20% |
| **Complexity** | Cyclomatic complexity, nesting depth, file size | 15% |
| **Churn rate** | How often this file has changed recently | 10% |
| **Test coverage** | Does this file have corresponding tests? | 10% |
| **Criticality** | Is this auth, payments, data, or core business logic? | 10% |

```bash
# Churn rate: how often files changed in last 30 days
git log --since="30 days ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -20

# File complexity indicator (line count as proxy)
wc -l <changed-files>
```

**Risk score = weighted sum across all factors**

| Score range | Risk level | Action |
|---|---|---|
| 4.0 - 5.0 | **Critical** | Requires thorough testing, review by senior, consider incremental rollout |
| 3.0 - 3.9 | **High** | Dedicated test cases needed, regression suite required |
| 2.0 - 2.9 | **Medium** | Standard testing, monitor after deploy |
| 1.0 - 1.9 | **Low** | Smoke test sufficient, low monitoring priority |

### 4. Identify Fragility Indicators

Check for known fragility patterns:

```bash
# God files (very large files)
find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" \) ! -path "*/node_modules/*" -exec wc -l {} + | sort -rn | head -10

# High-churn files (changed frequently)
git log --since="90 days ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -15

# Files with many imports (high coupling)
grep -c "^import \|^from \|require(" --include="*.py" --include="*.js" --include="*.ts" -r . 2>/dev/null | sort -t: -k2 -rn | head -15

# Files changed together frequently (hidden coupling)
git log --since="90 days ago" --name-only --pretty=format:"---" | awk '/^---$/{if(NR>1)for(i in files)for(j in files)if(i<j)print files[i]" <-> "files[j]; delete files; next}{files[$0]=1}' | sort | uniq -c | sort -rn | head -10
```

**Fragility indicators:**
- **God file**: > 500 lines, many responsibilities
- **High churn**: Changed > 10 times in 90 days
- **High coupling**: > 15 imports
- **Untested**: No corresponding test file
- **Hidden coupling**: Files that always change together
- **Deep nesting**: > 4 levels of if/for/while nesting
- **Long methods**: Functions > 50 lines

### 5. Load References (Only as Needed)

| Need | Read this file |
|---|---|
| Risk scoring methodology details | `references/risk-scoring-model.md` |
| Change impact pattern catalog | `references/change-impact-patterns.md` |
| Fragility indicator definitions | `references/fragility-indicators.md` |

### 6. Generate Test Priority Recommendations

Based on risk scores, output prioritized testing order:

```
Priority 1 (Test immediately):
  - <highest risk changes — specific files and what to test>

Priority 2 (Test before merge):
  - <high risk items>

Priority 3 (Include in regression):
  - <medium risk items>

Priority 4 (Smoke test sufficient):
  - <low risk items>
```

Map each priority item to a suggested skill:
- API changes → `api-test-generator`
- UI changes → `e2e-test-generator`
- Auth changes → `security-test-generator`
- Input handling → `input-validation-tester`

### 7. Produce Standard Report

```markdown
## Risk Analysis Report

- **Scope**: <PR #N | module X | release Y>
- **Files analyzed**: <count>
- **Overall risk level**: <Critical | High | Medium | Low>
- **Blast radius**: <count of affected files/modules>

### Change Summary
| File | Change type | Lines +/- | Dependents | Risk score |
|---|---|---|---|---|
| <file> | <logic/refactor/schema/config> | <+n/-m> | <count> | <1-5> |

### Risk Heat Map
| Module | Size | Churn | Coupling | Coverage | Overall risk |
|---|---|---|---|---|---|
| <module> | <score> | <score> | <score> | <score> | <weighted> |

### Impact Graph
\`\`\`
<changed-file>
├── <direct-dependent-1>
│   ├── <transitive-dependent-1>
│   └── <transitive-dependent-2>
└── <direct-dependent-2>
\`\`\`

### Fragility Warnings
- <god files, high-churn areas, untested modules>

### Test Priority Recommendations
| Priority | Area | Reason | Suggested skill |
|---|---|---|---|
| P0 | <area> | <reason> | <skill> |
| P1 | <area> | <reason> | <skill> |
| P2 | <area> | <reason> | <skill> |

### Deployment Recommendations
- <incremental rollout? feature flag? canary?>
- <monitoring focus areas after deploy>
- <rollback indicators>
```

## Fallback Behavior (Explicit)

### Fallback A: No Git History

Condition: Not a git repo or no history available.

Action:
1. Perform static analysis only (file size, imports, complexity)
2. Skip churn rate and change-together analysis
3. Note reduced accuracy in report

### Fallback B: Monorepo with Unclear Boundaries

Condition: Large repo with no clear module boundaries.

Action:
1. Ask user to specify scope (directory, service, module)
2. Analyze within that scope
3. Flag cross-boundary dependencies

### Fallback C: No Test Files Found

Condition: Zero test coverage.

Action:
1. Flag ALL changed areas as high risk for "no test coverage"
2. Recommend starting test creation with highest-risk modules
3. Map each module to appropriate generator skill

## Done Criteria

- Analysis scope defined and confirmed.
- All changed files scored on risk factors.
- Blast radius calculated (direct and transitive dependents).
- Fragility indicators identified.
- Test priorities recommended with skill mapping.
- Report follows standard template.

## Resources

- Risk scoring model: `references/risk-scoring-model.md`
- Change impact patterns: `references/change-impact-patterns.md`
- Fragility indicators: `references/fragility-indicators.md`

## Source Links

- [Risk-Based Testing - ISTQB](https://www.istqb.org/)
- [Code Churn and Defect Prediction](https://research.google/pubs/pub41145/)
- [Accelerate — DORA Metrics](https://dora.dev/)
- [Software Design X-Rays — Adam Tornhill](https://pragprog.com/titles/atevol/software-design-x-rays/)
