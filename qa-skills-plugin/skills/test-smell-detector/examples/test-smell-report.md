# Example: Test Smell Detection Report

## Test Smell Detection Report

- **Target**: `tests/api`
- **Test files analyzed**: 12
- **Test cases analyzed**: 67
- **Framework**: pytest
- **Overall health**: NEEDS ATTENTION

### Critical

- `tests/api/test_checkout.py:18` has no real assertion after calling the API.

### High

- `tests/api/test_orders.py:77` uses `time.sleep(2)` instead of waiting for a specific condition.
- `tests/api/test_payments.py:44` calls a real sandbox URL directly, making the test network-dependent.

### Medium

- `tests/api/test_users.py:91` duplicates the same payload setup already used in three nearby tests.
- `tests/api/test_checkout.py:102` contains 42 lines of logic in a single test body.

### Low

- `tests/api/test_misc.py:11` uses the name `test_stuff`, which does not explain expected behavior.

### Recommended Refactoring

- Replace `sleep()` with polling or explicit state checks.
- Move repeated payload creation into fixtures or factories.
- Split multi-purpose tests into smaller single-behavior tests.
- Replace weak or missing assertions with response body and side-effect assertions.
