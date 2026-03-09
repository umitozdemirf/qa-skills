# Edge Case Catalog

## Strings
- Empty string `""`
- Null / None / undefined
- Whitespace only `"   "`, tabs, newlines
- Single character `"a"`
- Maximum length string
- Unicode: CJK, Arabic, emoji, combining characters
- Special characters: `<>&"'\/`
- SQL metacharacters: `' " ; -- /*`
- Newlines within string: `"line1\nline2"`

## Numbers
- Zero (0, 0.0, -0)
- Negative numbers
- MIN_INT / MAX_INT boundaries
- Floating point precision: 0.1 + 0.2
- Very large numbers (overflow)
- Very small numbers (underflow)
- NaN, Infinity, -Infinity
- Leading zeros: "007"

## Collections (Arrays / Lists)
- Empty collection `[]`
- Single element `[x]`
- Duplicate elements
- Maximum size
- Nested collections
- Mixed types (if dynamically typed)
- Null elements within collection

## Dates / Times
- Epoch: 1970-01-01
- Y2K38: 2038-01-19
- Leap year: Feb 29
- Non-leap year: Feb 28
- Month boundaries: Jan 31, Feb 28/29, Apr 30
- Year boundaries: Dec 31 → Jan 1
- DST transitions
- Midnight: 00:00:00 vs 24:00:00
- Timezone extremes: UTC+14, UTC-12

## Files
- Empty file (0 bytes)
- Very large file
- Binary content with text extension
- Filename with spaces, unicode, special chars
- No file extension
- Double extension (.tar.gz, .jpg.exe)
- Path traversal in name: ../../etc/passwd
- Symlinks

## Network / API
- Timeout (slow response)
- Connection refused
- DNS resolution failure
- Empty response body
- Malformed JSON/XML
- HTTP 0 (connection dropped)
- Very large response
- Concurrent requests (race condition)

## Authentication
- Expired token
- Malformed token
- Empty token
- Token for deleted user
- Token from different environment
- Concurrent login/logout

## Database
- NULL columns
- Empty string vs NULL
- Maximum field length
- Foreign key to deleted record
- Concurrent updates (optimistic locking)
- Transaction rollback
- Connection pool exhaustion

## Boolean / Logic
- True, False, Null (three-state logic)
- Truthy/falsy in dynamic languages: 0, "", [], {}, undefined
- Double negation
- Short-circuit evaluation edge cases

## Pagination
- Page 0 (invalid?)
- Page 1 (first)
- Last page
- Beyond last page
- Page size 0
- Page size 1
- Very large page size
- Negative page number
- Total count = 0 (no results)
- Total count = 1 (single result)
- Total count = page_size (exactly one page)
