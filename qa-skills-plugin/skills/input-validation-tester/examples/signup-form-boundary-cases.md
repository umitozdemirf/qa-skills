# Example: Signup Form Boundary Cases

## Input Validation Test Data Report

- **Target**: `POST /api/signup`
- **Fields analyzed**: 4
- **Test cases generated**: 18

### Field: email (string, required, email format, max 254)

| # | Input | Category | Expected Result | Reason |
|---|---|---|---|---|
| 1 | `""` | empty | 400 | required field |
| 2 | `"user@example.com"` | valid | 201 | valid email |
| 3 | `"user@"` | invalid-format | 400 | incomplete domain |
| 4 | `"a...a@example.com"` | boundary-max | 201 | exact max length |
| 5 | `"a...aa@example.com"` | boundary-max+1 | 400 | exceeds max length |

### Field: password (string, required, min 12, max 128)

| # | Input | Category | Expected Result | Reason |
|---|---|---|---|---|
| 1 | `"short1!"` | boundary-min-1 | 400 | below minimum length |
| 2 | `"LongEnough12!"` | boundary-min | 201 | valid minimum |
| 3 | `" "` | whitespace | 400 | invalid value |
| 4 | `"P@ssw0rd🚀123"` | unicode | 201 | valid unicode password |

### Field: birthDate (date, optional, ISO-8601)

| # | Input | Category | Expected Result | Reason |
|---|---|---|---|---|
| 1 | `"2024-02-29"` | leap-year-valid | 201 | valid leap day |
| 2 | `"2023-02-29"` | leap-year-invalid | 400 | invalid date |
| 3 | `"not-a-date"` | type-mismatch | 400 | invalid format |

### Coverage

- Boundary values: yes
- Equivalence partitions: yes
- Special characters: yes
- Unicode/encoding: yes
- Null/empty: yes
- Type mismatch: yes
