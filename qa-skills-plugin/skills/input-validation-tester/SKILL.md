---
name: input-validation-tester
description: Generate boundary value, equivalence partitioning, and edge case test data for input validation testing.
---

# Input Validation Tester

Generate comprehensive input validation test cases using boundary value analysis, equivalence partitioning, and special character testing. Covers strings, numbers, dates, emails, files, and custom formats.

## Trigger Phrases

Use this skill when the user asks for tasks like:
- "Generate boundary tests for this input"
- "Create edge case tests for this form"
- "Test input validation for this field"
- "Generate invalid input test data"
- "What edge cases should I test for this parameter?"
- "Create fuzz-like test data"
- "Test boundary values for this API"

## Use / Do Not Use

Use this skill for:
- Generating test data sets for input fields/parameters
- Boundary value analysis for numeric, string, and date inputs
- Special character and encoding test cases
- Equivalence class partitioning
- Generating negative test scenarios for validation logic

Do not use this skill for:
- Security-specific payloads like SQLi/XSS (use `security-test-generator`)
- Full API test suite generation (use `api-test-generator`)
- Performance/load data generation (out of scope for this skill pack today; use a dedicated performance workflow/tool)

## Local Files In This Skill

- References:
  - `references/boundary-value-analysis.md`
  - `references/special-characters.md`
  - `references/data-type-edge-cases.md`

## Deterministic Execution Flow (Required)

### 1. Discovery — Identify Input Fields

**Option A: From source code**

```bash
# Find validation rules in code
grep -rn "required\|min_length\|max_length\|MinLength\|MaxLength\|@Valid\|@NotNull\|@Size\|@Pattern\|@Email\|validator\|Yup\.\|Zod\.\|pydantic" --include="*.py" --include="*.java" --include="*.ts" --include="*.js" . | head -30
```

```bash
# Find model/schema definitions
grep -rn "class.*Model\|class.*Schema\|interface.*Request\|type.*Input\|class.*DTO" --include="*.py" --include="*.java" --include="*.ts" --include="*.js" . | head -20
```

**Option B: From API spec**

```bash
find . -maxdepth 3 -name "openapi.*" -o -name "swagger.*" | head -5
```

Parse request body schemas for field types, constraints, and required flags.

**Option C: User-provided field definitions**

Parse user description for field names, types, and constraints.

### 2. Classify Each Input Field

For each field, determine:
- **Data type**: string, integer, float, boolean, date, email, URL, phone, enum, file, array, object
- **Constraints**: min/max length, min/max value, pattern/regex, required/optional, unique
- **Format**: email, URL, phone, UUID, ISO date, custom regex

### 3. Load References (Only as Needed)

| Need | Read this file |
|---|---|
| Boundary value methodology | `references/boundary-value-analysis.md` |
| Special char / encoding test data | `references/special-characters.md` |
| Type-specific edge cases | `references/data-type-edge-cases.md` |

### 4. Generate Test Data per Field Type

#### String Fields

| Category | Test values |
|---|---|
| Empty/null | `""`, `null`, `undefined`, whitespace-only `"   "` |
| Boundary length | min-1, min, min+1, max-1, max, max+1 characters |
| Unicode | `"名前"`, `"Ümit"`, `"🎉🚀"`, RTL text `"مرحبا"` |
| Special chars | `"<script>alert(1)</script>"`, `"'; DROP TABLE--"`, `"../../etc/passwd"` |
| Long strings | 1000 chars, 10000 chars, max_int chars |
| Whitespace | leading, trailing, multiple internal spaces, tabs, newlines |
| Encoding | UTF-8 BOM, Latin-1, null bytes `"\x00"` |

#### Numeric Fields (Integer/Float)

| Category | Test values |
|---|---|
| Boundaries | min-1, min, min+1, max-1, max, max+1 |
| Zero | 0, -0, +0 |
| Negative | -1, MIN_INT |
| Large | MAX_INT, MAX_INT+1, MAX_FLOAT |
| Decimal precision | 0.1+0.2, very small (1e-10), very large (1e308) |
| Non-numeric | `"abc"`, `"12.34.56"`, `"1e999"`, `""`, `NaN`, `Infinity` |

#### Date/Time Fields

| Category | Test values |
|---|---|
| Boundaries | 1970-01-01, 2038-01-19, 9999-12-31, 0000-01-01 |
| Invalid dates | 2024-02-30, 2024-13-01, 2024-00-00 |
| Leap year | 2024-02-29 (valid), 2023-02-29 (invalid) |
| Timezones | UTC, UTC+14, UTC-12, DST transition dates |
| Formats | ISO 8601, Unix timestamp, human-readable |
| Edge | Midnight, 23:59:59, daylight saving transitions |

#### Email Fields

| Category | Test values |
|---|---|
| Valid | `"user@example.com"`, `"user+tag@example.com"`, `"user@sub.domain.com"` |
| Invalid | `"@example.com"`, `"user@"`, `"user@.com"`, `"user@@example.com"`, no-at-sign |
| Edge | 254 char email, special local parts, IP domain `"user@[127.0.0.1]"` |

#### File Upload Fields

| Category | Test values |
|---|---|
| Type | Allowed MIME types, disallowed types, double extensions (.jpg.exe) |
| Size | 0 bytes, 1 byte, max size, max+1 byte |
| Name | Special chars in filename, very long name, no extension, path traversal (../../../) |
| Content | Empty file, corrupted content with valid extension, polyglot files |

#### Array/List Fields

| Category | Test values |
|---|---|
| Empty | `[]`, missing field |
| Size | 1 item, max items, max+1 items |
| Duplicates | All same values, mixed |
| Nested | Deeply nested arrays, mixed types |

### 5. Generate Output

Output format based on user preference:

**A. Structured test data table (default)**

```markdown
### Field: <field_name> (<type>, <constraints>)

| # | Input | Category | Expected Result | Reason |
|---|---|---|---|---|
| 1 | `""` | empty | 400/reject | required field |
| 2 | `"a"` | boundary-min | 200/accept | meets min length |
| ... | ... | ... | ... | ... |
```

**B. Parameterized test code (if user requests)**

```python
@pytest.mark.parametrize("value,expected_status", [
    ("", 400),
    ("a", 200),
    ("a" * 256, 400),
    (None, 400),
    ("<script>alert(1)</script>", 400),
])
def test_field_name_validation(client, value, expected_status):
    response = client.post("/endpoint", json={"field_name": value})
    assert response.status_code == expected_status
```

**C. JSON test data set**

```json
{
  "field_name": {
    "valid": ["value1", "value2"],
    "invalid": [
      {"value": "", "reason": "empty string", "expected": 400},
      {"value": null, "reason": "null value", "expected": 400}
    ]
  }
}
```

### 6. Output Summary

```markdown
## Input Validation Test Data Report

- **Target**: <endpoint/form/module>
- **Fields analyzed**: <count>
- **Test cases generated**: <count>

### Per Field Summary
| Field | Type | Constraints | Valid cases | Invalid cases | Total |
|---|---|---|---|---|---|
| <name> | <type> | <constraints> | <n> | <n> | <n> |

### Coverage
- Boundary values: ✓
- Equivalence partitions: ✓
- Special characters: ✓
- Unicode/encoding: ✓
- Null/empty: ✓
- Type mismatch: ✓
```

## Fallback Behavior (Explicit)

### Fallback A: No Constraints Discoverable

Action:
1. Use sensible defaults (string max 255, int max 2^31-1, etc.)
2. Mark constraints as assumed
3. Ask user to confirm or provide actual constraints

### Fallback B: Custom/Complex Field Type

Action:
1. Ask user for format specification or regex pattern
2. Generate tests based on provided format
3. Include standard edge cases (null, empty, too long)

## Done Criteria

- All input fields identified and classified.
- Test data covers boundary values, equivalence classes, and special characters.
- Expected results (accept/reject) documented per test case.
- Output format matches user preference.
- Summary report provided.

## Resources

- Boundary value analysis: `references/boundary-value-analysis.md`
- Special characters: `references/special-characters.md`
- Data type edge cases: `references/data-type-edge-cases.md`

## Source Links

- [ISTQB Boundary Value Analysis](https://www.istqb.org/)
- [OWASP Input Validation Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html)
- [Big List of Naughty Strings](https://github.com/minimaxir/big-list-of-naughty-strings)
