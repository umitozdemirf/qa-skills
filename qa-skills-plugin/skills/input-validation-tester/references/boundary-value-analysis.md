# Boundary Value Analysis

## Methodology

Boundary Value Analysis (BVA) tests values at the edges of input domains where bugs are most likely to occur.

For any range [min, max], test these 5 values:
1. **min - 1** (just below minimum — invalid)
2. **min** (minimum boundary — valid)
3. **min + 1** (just above minimum — valid)
4. **max - 1** (just below maximum — valid)
5. **max** (maximum boundary — valid)
6. **max + 1** (just above maximum — invalid)

## Examples by Type

### Integer field: age (1-120)
| Value | Category | Expected |
|---|---|---|
| 0 | min - 1 | Reject |
| 1 | min | Accept |
| 2 | min + 1 | Accept |
| 119 | max - 1 | Accept |
| 120 | max | Accept |
| 121 | max + 1 | Reject |

### String field: username (3-20 chars)
| Value | Category | Expected |
|---|---|---|
| "ab" (2 chars) | min - 1 | Reject |
| "abc" (3 chars) | min | Accept |
| "abcd" (4 chars) | min + 1 | Accept |
| 19 chars | max - 1 | Accept |
| 20 chars | max | Accept |
| 21 chars | max + 1 | Reject |

### Float field: price (0.01 - 99999.99)
| Value | Category | Expected |
|---|---|---|
| 0.00 | min - 0.01 | Reject |
| 0.01 | min | Accept |
| 0.02 | min + 0.01 | Accept |
| 99999.98 | max - 0.01 | Accept |
| 99999.99 | max | Accept |
| 100000.00 | max + 0.01 | Reject |

### Date field: birth_date (1900-01-01 to today)
| Value | Category | Expected |
|---|---|---|
| 1899-12-31 | min - 1 day | Reject |
| 1900-01-01 | min | Accept |
| 1900-01-02 | min + 1 day | Accept |
| yesterday | max - 1 day | Accept |
| today | max | Accept |
| tomorrow | max + 1 day | Reject |

## Equivalence Partitioning

Complement BVA with equivalence classes:
- **Valid partition**: Any value within the valid range
- **Below minimum**: Values below the range
- **Above maximum**: Values above the range
- **Wrong type**: Completely different data type
- **Empty/null**: Absence of value

## Combined Approach

For a field with constraints:
```
name: string, required, 2-50 chars, alphanumeric + spaces
```

Test matrix:
| # | Value | Partition | BVA | Expected |
|---|---|---|---|---|
| 1 | null | empty | — | Reject (required) |
| 2 | "" | empty | — | Reject (required) |
| 3 | "a" | below min | min-1 | Reject |
| 4 | "ab" | valid | min | Accept |
| 5 | "abc" | valid | min+1 | Accept |
| 6 | 49 chars | valid | max-1 | Accept |
| 7 | 50 chars | valid | max | Accept |
| 8 | 51 chars | above max | max+1 | Reject |
| 9 | "ab@#$" | wrong chars | — | Reject (pattern) |
| 10 | 12345 | wrong type | — | Reject (type) |
| 11 | "  ab  " | whitespace | — | Accept or trim? (verify) |
