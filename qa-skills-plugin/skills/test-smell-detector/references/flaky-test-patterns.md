# Flaky Test Patterns

## Definition

A flaky test is a test that passes and fails intermittently without any code change. Flaky tests erode trust in the test suite and slow down development.

## Root Cause Categories

### 1. Timing and Concurrency

**Symptoms**: Test passes locally, fails in CI (or vice versa)

- Fixed sleep/wait that's too short on slow machines
- Race conditions in async code
- Port conflicts between parallel tests
- Database transaction timing

**Detection signals**:
```
time.sleep(
setTimeout(
Thread.sleep(
await new Promise(r => setTimeout
```

**Fix**: Replace with explicit waits, use retry logic, isolate resources per test.

### 2. Shared State

**Symptoms**: Test fails when run after specific other test

- Tests sharing database records
- Global variables modified between tests
- Shared file system resources
- Singleton instances carrying state

**Detection signals**:
- Test passes in isolation (`pytest -k test_name`) but fails in full suite
- Test order matters

**Fix**: Use fixtures with setup/teardown, database transactions with rollback, fresh instances per test.

### 3. External Dependencies

**Symptoms**: Test fails randomly, especially in CI

- Network calls to real services
- DNS resolution
- Third-party API rate limits
- External service downtime

**Detection signals**:
```
requests.get("https://
fetch("https://
HttpClient.*("https://
```

**Fix**: Mock/stub external services, use recorded responses (VCR/cassettes), use test doubles.

### 4. Time-Dependent Logic

**Symptoms**: Test fails at specific times (midnight, month end, DST)

- Using `datetime.now()` without mocking
- Timezone assumptions
- Date calculations crossing boundaries

**Detection signals**:
```
datetime.now()
new Date()
Date.now()
System.currentTimeMillis()
```

**Fix**: Inject clock/time, use time-freezing libraries (freezegun, jest.useFakeTimers).

### 5. Resource Leaks

**Symptoms**: Test passes first N times, then fails

- File handles not closed
- Database connections not released
- Memory accumulation
- Port exhaustion

**Fix**: Use context managers, connection pools, proper cleanup in fixtures.

### 6. Non-Deterministic Data

**Symptoms**: Test fails with certain generated values

- Random data hitting edge cases
- UUID ordering assumptions
- Floating point comparison
- Hash map iteration order

**Detection signals**:
```
random.
Math.random()
uuid4()
faker.
```

**Fix**: Seed random generators, use exact comparisons with tolerance, don't depend on ordering.

## Detection Strategy

1. Run test suite 5+ times, record pass/fail per test
2. Flag tests that flip between pass and fail
3. Run flaky candidates in isolation — if they pass alone, likely shared state
4. Check CI history for intermittent failures
5. Grep for anti-pattern signals listed above

## Severity Classification

| Frequency | Impact | Action |
|---|---|---|
| > 20% failure rate | Blocks CI/CD | Fix immediately — quarantine until fixed |
| 5-20% failure rate | Slows development | Fix within sprint |
| < 5% failure rate | Annoyance | Track, fix when touching that area |
