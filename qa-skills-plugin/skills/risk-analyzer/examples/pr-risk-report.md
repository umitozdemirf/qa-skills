# Example: PR Risk Analysis Report

## Risk Analysis Report

- **Scope**: PR #184 - checkout tax and payment callback changes
- **Files analyzed**: 6
- **Overall risk level**: High
- **Blast radius**: 4 modules

### Change Summary

| File | Change type | Lines +/- | Dependents | Risk score |
|---|---|---|---|---|
| `services/payments/callback_handler.py` | Logic | +84/-21 | 3 | 4.6 |
| `services/checkout/tax_service.py` | Logic | +47/-12 | 2 | 4.1 |
| `api/routes/checkout.py` | API | +28/-10 | 2 | 3.9 |
| `tests/api/test_checkout.py` | Tests | +35/-4 | 0 | 2.2 |

### Fragility Warnings

- `services/payments/callback_handler.py` changed 11 times in the last 90 days.
- Payment callback logic is only partially covered by automated integration tests.
- `tax_service.py` is coupled to shipping-country and promotion rules, increasing regression risk.

### Test Priority Recommendations

| Priority | Area | Reason | Suggested skill |
|---|---|---|---|
| P0 | Payment callback idempotency | Direct revenue impact and duplicate-charge risk | `service-test-generator` |
| P0 | Tax recalculation after address change | Price accuracy and order total correctness | `api-test-generator` |
| P1 | Authorization around checkout endpoints | Protected endpoints changed in same PR | `security-test-generator` |
| P1 | Invalid address input handling | Validation path touched by new tax logic | `input-validation-tester` |
| P2 | Confirmation email side effects | Indirect dependency only | `test-plan-generator` |

### Deployment Recommendations

- Deploy behind a feature flag for callback processor if possible.
- Monitor duplicate payment intents, tax mismatch errors, and checkout 5xx rates.
- Prepare rollback if payment callback failure rate exceeds baseline by 2x.
