# Example: Coverage Gap Report

## Test Coverage Analysis Report

- **Target**: `services/checkout`
- **Source files**: 7
- **Test files**: 3
- **Test-to-source ratio**: 0.43
- **Overall coverage health**: GAPS FOUND

### Coverage Summary

| Metric | Value |
|---|---|
| Source files with tests | 4/7 (57%) |
| Public functions tested | 11/19 (58%) |
| API endpoints tested | 5/8 (62%) |
| Error paths tested | 2/9 (22%) |

### Untested Source Files

| File | Functions | Risk |
|---|---|---|
| `services/checkout/tax_rounding.py` | `round_tax`, `normalize_currency_precision` | High |
| `services/checkout/fraud_flags.py` | `build_risk_flags` | Medium |

### Untested Endpoints

| Method | Path | Source file |
|---|---|---|
| POST | `/api/checkout/quote` | `api/routes/checkout.py:44` |
| POST | `/api/checkout/apply-coupon` | `api/routes/checkout.py:88` |
| DELETE | `/api/cart/items/{item_id}` | `api/routes/cart.py:63` |

### Missing Edge Case Tests

| Function | Missing scenario |
|---|---|
| `round_tax` | values exactly on half-cent boundary |
| `build_quote` | empty cart with valid customer session |
| `apply_coupon` | expired coupon and coupon for wrong region |

### Recommended Actions

1. Add API tests for quote and coupon endpoints with `api-test-generator`.
2. Add boundary-value cases for tax rounding with `input-validation-tester`.
3. Add regression checks for empty-cart and expired-coupon flows.
