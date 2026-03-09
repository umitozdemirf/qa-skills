# Data Type Edge Cases

## Email
| Test | Value | Expected |
|---|---|---|
| Standard valid | user@example.com | Accept |
| Subdomain | user@sub.domain.com | Accept |
| Plus addressing | user+tag@example.com | Accept |
| Dots in local | first.last@example.com | Accept |
| IP domain | user@[127.0.0.1] | Depends on spec |
| No local part | @example.com | Reject |
| No domain | user@ | Reject |
| No at sign | userexample.com | Reject |
| Double at | user@@example.com | Reject |
| Spaces | user @example.com | Reject |
| Leading dot | .user@example.com | Reject |
| Max length (254) | [64-char-local]@[domain-to-254-total] | Accept |
| Over max length | [255+ chars] | Reject |
| Unicode local | ünit@example.com | Depends on spec |

## URL
| Test | Value | Expected |
|---|---|---|
| HTTP | http://example.com | Accept |
| HTTPS | https://example.com | Accept |
| With path | https://example.com/path | Accept |
| With query | https://example.com?q=1 | Accept |
| With fragment | https://example.com#section | Accept |
| With port | https://example.com:8080 | Accept |
| No protocol | example.com | Depends on spec |
| FTP | ftp://example.com | Depends on spec |
| JavaScript | javascript:alert(1) | Reject |
| Data URI | data:text/html,<script> | Reject |
| Internal IP | http://192.168.1.1 | Context-dependent |
| Localhost | http://localhost | Context-dependent |

## Phone Number
| Test | Value | Expected |
|---|---|---|
| International | +1-555-123-4567 | Accept |
| With spaces | +1 555 123 4567 | Accept |
| Compact | +15551234567 | Accept |
| Local format | (555) 123-4567 | Depends on spec |
| Too short | +1-55 | Reject |
| Too long | +1-555-123-4567-890-123 | Reject |
| Letters | +1-555-CALL-ME | Reject |
| All zeros | 000-000-0000 | Reject |

## UUID
| Test | Value | Expected |
|---|---|---|
| Valid v4 | 550e8400-e29b-41d4-a716-446655440000 | Accept |
| Uppercase | 550E8400-E29B-41D4-A716-446655440000 | Depends |
| No dashes | 550e8400e29b41d4a716446655440000 | Depends |
| Too short | 550e8400-e29b-41d4-a716 | Reject |
| Invalid chars | 550e8400-e29b-41d4-a716-44665544ZZZZ | Reject |
| All zeros | 00000000-0000-0000-0000-000000000000 | Depends |

## Password
| Test | Value | Expected |
|---|---|---|
| Min length | "aB1!aB1!" (8 chars typical) | Accept |
| Below min | "aB1!" (4 chars) | Reject |
| Max length | 128 chars | Accept |
| Over max | 129+ chars | Depends |
| No uppercase | "abcd1234!" | Reject (if required) |
| No lowercase | "ABCD1234!" | Reject (if required) |
| No number | "abcdEFGH!" | Reject (if required) |
| No special | "abcdEFGH1" | Reject (if required) |
| Common password | "password123" | Reject (if checked) |
| Unicode | "pässwörd123!" | Depends |
| Spaces | "pass word 123!" | Depends |

## Currency/Money
| Test | Value | Expected |
|---|---|---|
| Standard | 19.99 | Accept |
| Zero | 0.00 | Depends |
| Negative | -10.00 | Depends |
| No decimals | 20 | Accept (auto .00) |
| One decimal | 19.9 | Accept (auto 19.90) |
| Three decimals | 19.999 | Reject or round |
| Very large | 999999999.99 | Depends on max |
| Comma format | 1,000.00 | Depends on locale |
| Currency symbol | $19.99 | Reject (if numeric only) |

## File Upload
| Test | Value | Expected |
|---|---|---|
| Valid type | image.jpg (JPEG content) | Accept |
| Wrong extension | script.jpg (JS content) | Reject |
| No extension | myfile (JPEG content) | Depends |
| Double extension | image.jpg.exe | Reject |
| Zero bytes | empty.jpg | Reject |
| Max size | exactly max_size bytes | Accept |
| Over max | max_size + 1 byte | Reject |
| Path in name | ../../etc/passwd.jpg | Reject |
| Unicode name | 画像.jpg | Depends |
| Very long name | "a" * 256 + ".jpg" | Reject |
