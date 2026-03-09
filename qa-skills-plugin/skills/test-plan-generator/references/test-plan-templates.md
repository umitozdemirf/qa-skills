# Test Plan Templates

## Feature Test Plan

```markdown
# Test Plan: [Feature Name]

## 1. Overview
- **Feature**: [description]
- **Author**: [QA engineer]
- **Date**: [date]
- **Version**: [version]
- **Status**: Draft | In Review | Approved

## 2. Scope
### In Scope
- [what will be tested]

### Out of Scope
- [what will NOT be tested and why]

## 3. Risk Assessment
| Area | Risk Level | Reason |
|---|---|---|
| [area] | [Critical/High/Medium/Low] | [reason] |

## 4. Test Strategy
| Test Type | Scope | Tool | Automated? |
|---|---|---|---|
| Unit | [scope] | [tool] | Yes |
| Integration | [scope] | [tool] | Yes |
| E2E | [scope] | [tool] | Yes/No |
| Manual Exploratory | [scope] | — | No |

## 5. Test Cases

### P0 — Release Blockers
| ID | Test Case | Precondition | Steps | Expected | Automated |
|---|---|---|---|---|---|
| TC-001 | [name] | [precondition] | [steps] | [expected] | [yes/no] |

### P1 — High Priority
| ID | Test Case | Precondition | Steps | Expected | Automated |
|---|---|---|---|---|---|

### P2 — Medium Priority
| ID | Test Case | Precondition | Steps | Expected | Automated |
|---|---|---|---|---|---|

## 6. Acceptance Criteria
- [ ] All P0 tests pass
- [ ] All P1 tests pass
- [ ] No critical bugs open
- [ ] Code coverage >= [threshold]

## 7. Environment
- **URL**: [environment URL]
- **Test data**: [data requirements]
- **Accounts**: [test accounts needed]
- **Feature flags**: [flags to toggle]

## 8. Schedule
| Phase | Start | End | Owner |
|---|---|---|---|
| Test design | [date] | [date] | [person] |
| Test execution | [date] | [date] | [person] |
| Bug fix verification | [date] | [date] | [person] |

## 9. Exit Criteria
- All P0 and P1 tests executed
- Bug fix verification complete
- Stakeholder sign-off received
```

## PR Test Checklist (Lightweight)

```markdown
## Test Checklist for PR #[number]

### Changes
- [summary of changes]

### Risk: [Low/Medium/High/Critical]

### Tests
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] E2E tests added/updated (if UI change)
- [ ] Manual testing completed

### Manual Test Steps
1. [step 1]
2. [step 2]
3. Expected: [result]

### Regression Areas
- [ ] [area 1] — smoke tested
- [ ] [area 2] — smoke tested

### Edge Cases Verified
- [ ] [edge case 1]
- [ ] [edge case 2]
```

## Release Test Plan (Comprehensive)

```markdown
# Release Test Plan: v[X.Y.Z]

## Release Scope
- [list of features/PRs included]

## Critical Paths (Must Pass)
1. [critical flow 1] — Owner: [name]
2. [critical flow 2] — Owner: [name]

## Regression Suite
- [ ] Full regression: [link to test run]
- [ ] Performance baseline: [link]
- [ ] Security scan: [link]

## Rollback Plan
- [rollback procedure]
- [rollback indicators: what metrics to watch]

## Sign-off
| Role | Name | Status | Date |
|---|---|---|---|
| QA Lead | | | |
| Dev Lead | | | |
| Product | | | |
```
