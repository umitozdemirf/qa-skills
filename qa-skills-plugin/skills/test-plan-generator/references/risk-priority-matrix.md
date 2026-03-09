# Risk Priority Matrix

## Risk Factors

### User Impact (Weight: 25%)

| Score | Description |
|---|---|
| 5 | All users affected, core functionality broken |
| 4 | Many users affected, important feature impacted |
| 3 | Some users affected, workaround exists |
| 2 | Few users affected, minor inconvenience |
| 1 | Internal only, no user-visible impact |

### Change Complexity (Weight: 20%)

| Score | Description |
|---|---|
| 5 | Schema migration, API contract change, multi-service change |
| 4 | New feature with complex logic, auth changes |
| 3 | Moderate logic change, new endpoints |
| 2 | Simple feature addition, configuration change |
| 1 | Typo fix, comment update, minor style change |

### Historical Defect Rate (Weight: 20%)

| Score | Description |
|---|---|
| 5 | Area has had 5+ bugs in last quarter |
| 4 | Area has had 3-4 bugs in last quarter |
| 3 | Area has had 1-2 bugs in last quarter |
| 2 | Area has had bugs but not recently |
| 1 | No known defect history |

### Dependency Count (Weight: 15%)

| Score | Description |
|---|---|
| 5 | 10+ downstream services/modules depend on this |
| 4 | 5-9 downstream dependencies |
| 3 | 3-4 downstream dependencies |
| 2 | 1-2 downstream dependencies |
| 1 | No downstream dependencies (leaf node) |

### Test Coverage (Weight: 10%)

| Score | Description |
|---|---|
| 5 | 0% coverage — no tests exist |
| 4 | < 30% coverage |
| 3 | 30-60% coverage |
| 2 | 60-80% coverage |
| 1 | > 80% coverage with quality tests |

### Reversibility (Weight: 10%)

| Score | Description |
|---|---|
| 5 | Irreversible (data migration, external notification) |
| 4 | Hard to reverse (published API change, DB schema) |
| 3 | Reversible with effort (feature flag, config rollback) |
| 2 | Easy to reverse (quick redeploy) |
| 1 | Instant rollback (feature flag off) |

## Priority Mapping

| Risk Score | Priority | Testing Strategy |
|---|---|---|
| 4.0 - 5.0 | P0 — Release blocker | Full test coverage required, manual exploratory testing |
| 3.0 - 3.9 | P1 — Must test | Automated tests required, review by senior QA |
| 2.0 - 2.9 | P2 — Should test | Standard automated coverage |
| 1.0 - 1.9 | P3 — Smoke test | Basic sanity check, include in regression |

## Example Scoring

### Scenario: New payment endpoint

| Factor | Score | Weighted |
|---|---|---|
| User impact | 5 | 1.25 |
| Complexity | 4 | 0.80 |
| Defect history | 3 | 0.60 |
| Dependencies | 4 | 0.60 |
| Test coverage | 5 | 0.50 |
| Reversibility | 5 | 0.50 |
| **Total** | | **4.25 — P0** |

### Scenario: Update README

| Factor | Score | Weighted |
|---|---|---|
| User impact | 1 | 0.25 |
| Complexity | 1 | 0.20 |
| Defect history | 1 | 0.20 |
| Dependencies | 1 | 0.15 |
| Test coverage | 1 | 0.10 |
| Reversibility | 1 | 0.10 |
| **Total** | | **1.00 — P3** |
