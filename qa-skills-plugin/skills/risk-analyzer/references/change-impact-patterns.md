# Change Impact Patterns

## High-Impact Change Types

### Database Schema Changes
- **Risk**: Data loss, downtime, migration failures
- **Impact radius**: Every service reading/writing the table
- **Test focus**: Migration rollback, data integrity, query performance
- **Signals**: `ALTER TABLE`, `CREATE TABLE`, migration files, ORM model changes

### API Contract Changes
- **Risk**: Breaking downstream consumers
- **Impact radius**: All API clients (frontend, mobile, third-party)
- **Test focus**: Contract tests, backward compatibility, versioning
- **Signals**: Route changes, response schema changes, removed fields, status code changes

### Authentication/Authorization Changes
- **Risk**: Security bypass, access control failures
- **Impact radius**: Every protected endpoint
- **Test focus**: Auth flow, RBAC matrix, token handling, session management
- **Signals**: Auth middleware changes, permission model changes, JWT logic

### Shared Library/Core Module Changes
- **Risk**: Cascading failures across dependents
- **Impact radius**: All importing modules
- **Test focus**: All consumer tests, interface compatibility
- **Signals**: Changes to utils/, common/, shared/, core/, lib/ directories

### Configuration Changes
- **Risk**: Environment-specific failures
- **Impact radius**: Varies (could be entire service)
- **Test focus**: Deployment to each environment, feature flag behavior
- **Signals**: .env, config files, environment variables, feature flags

## Impact Assessment Patterns

### Direct Impact
Files that directly import or call the changed code.

```bash
# Find direct importers
grep -rl "from changed_module import\|import changed_module" --include="*.py" .
```

### Transitive Impact
Files that depend on files that depend on the changed code. Chain depth matters.

### Interface Impact
When a function signature, return type, or exception behavior changes:
- All callers must be verified
- Mock/stub updates in tests

### Data Impact
When data format, schema, or semantics change:
- All readers must handle new format
- Migration for existing data
- Cache invalidation

### Behavioral Impact
When logic changes without interface changes:
- Hardest to detect automatically
- Requires understanding expected behavior
- Integration/E2E tests are primary safety net

## Low-Impact Change Types

| Change | Why low impact |
|---|---|
| Documentation only | No runtime behavior change |
| Code formatting | Semantic equivalence |
| Internal refactor (same behavior) | Tests should catch regressions |
| Adding new unused code | No existing behavior affected |
| Dev tooling changes | No production impact |

## Impact Graph Construction

For a changed file `A`:

```
Level 0: A (changed)
Level 1: [files that import A] — direct impact
Level 2: [files that import Level 1 files] — transitive impact
Level 3: [files that import Level 2 files] — distant impact
```

Generally:
- **Level 0-1**: Must test
- **Level 2**: Should test (regression)
- **Level 3+**: Smoke test sufficient

## Hidden Coupling Patterns

### Temporal Coupling
Files that always change together (detectable from git history) but have no import relationship. Often indicates:
- Shared business rules duplicated across files
- Configuration that must stay in sync
- Undocumented contracts

### Data Coupling
Modules that share database tables or message queues without explicit code dependencies.

### Environmental Coupling
Services that share environment variables, config files, or infrastructure.
