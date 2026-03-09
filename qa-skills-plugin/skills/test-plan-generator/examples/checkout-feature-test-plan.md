# Example: Checkout Feature Test Plan

## Test Plan: Checkout Feature

### Overview

- **Scope**: Guest and authenticated checkout flow for web storefront
- **Type**: Feature
- **Risk level**: High
- **Estimated effort**: 2 QA days
- **Target environment**: Staging

### Risk Assessment

| Area | Impact | Complexity | History | Dependencies | Coverage | Risk Score |
|---|---|---|---|---|---|---|
| Cart totals | 5 | 4 | 3 | 4 | 3 | 4.10 |
| Payment authorization | 5 | 5 | 4 | 5 | 2 | 4.60 |
| Address validation | 4 | 3 | 2 | 2 | 3 | 3.10 |
| Order confirmation email | 3 | 2 | 3 | 4 | 2 | 2.95 |

### Test Cases

#### P0 - Must Pass

| ID | Test Case | Type | Steps | Expected Result | Status |
|---|---|---|---|---|---|
| TC-001 | Checkout with valid card | E2E | Add item, fill address, pay with valid card | Order created and confirmation shown | TODO |
| TC-002 | Prevent duplicate charge on refresh | Integration | Submit payment then refresh callback page | Single payment intent and single order | TODO |
| TC-003 | Authenticated user sees saved address | Functional | Login, open checkout | Saved address prefilled correctly | TODO |

#### P1 - Should Pass

| ID | Test Case | Type | Steps | Expected Result | Status |
|---|---|---|---|---|---|
| TC-004 | Invalid postal code rejected | Functional | Enter malformed postal code | Inline validation message shown | TODO |
| TC-005 | Expired card is rejected cleanly | Integration | Use expired test card | Error shown without order creation | TODO |
| TC-006 | Tax recalculates after country change | Functional | Change shipping country | Tax and total update correctly | TODO |

#### P2 - Nice to Have

| ID | Test Case | Type | Steps | Expected Result | Status |
|---|---|---|---|---|---|
| TC-007 | Browser back button during checkout | E2E | Move between cart and checkout with back button | State preserved correctly | TODO |
| TC-008 | Confirmation email rendering | Functional | Complete order | Email contains expected totals and items | TODO |

### Acceptance Criteria

- [ ] All P0 test cases pass
- [ ] All P1 test cases pass or have approved exceptions
- [ ] No Sev1 or Sev2 bug remains open
- [ ] Payment provider callbacks are verified in staging

### Regression Areas

- Promotions and coupon application
- Guest cart persistence
- Order history visibility

### Automation Mapping

| Test Case | Automatable | Recommended tool |
|---|---|---|
| TC-001 | Yes | `e2e-test-generator` |
| TC-002 | Yes | `service-test-generator` |
| TC-004 | Yes | `input-validation-tester` |
| TC-005 | Partial | `api-test-generator` |
