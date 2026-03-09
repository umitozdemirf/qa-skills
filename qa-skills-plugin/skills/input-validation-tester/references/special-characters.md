# Special Characters Test Data

## SQL Injection Characters
```
'
"
;
--
/*
*/
' OR '1'='1
' OR '1'='1'--
'; DROP TABLE users--
' UNION SELECT null--
1 OR 1=1
```

## XSS Payloads
```
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
javascript:alert(1)
" onmouseover="alert(1)
'><script>alert(1)</script>
<iframe src="javascript:alert(1)">
```

## Path Traversal
```
../../../etc/passwd
..\..\..\..\windows\system32\config\sam
....//....//etc/passwd
%2e%2e%2f%2e%2e%2f
```

## Command Injection
```
; ls -la
| cat /etc/passwd
$(whoami)
`id`
&& rm -rf /
```

## LDAP Injection
```
*
)(cn=*
*()|&'
```

## Unicode Edge Cases
```
\u0000 (null byte)
\uFEFF (BOM)
\u200B (zero-width space)
\u200E (LTR mark)
\u200F (RTL mark)
\uFFFD (replacement character)
```

## Encoding Variants
```
%00 (null byte URL encoded)
%0a (newline URL encoded)
%0d (carriage return URL encoded)
&#60; (HTML entity <)
&#x3C; (HTML hex entity <)
&lt; (HTML named entity <)
\x3c (JS escape <)
\u003c (Unicode escape <)
```

## Format-Breaking Characters
```
\n (newline)
\r (carriage return)
\t (tab)
\0 (null byte)
\\ (backslash)
```

## JSON-Breaking Characters
```
" (unescaped quote)
\ (unescaped backslash)
\n \r \t (control chars)
{"key": "value"} (nested JSON in string)
```

## Whitespace Variants
```
\x20 (regular space)
\t (tab)
\n (newline)
\r (carriage return)
\xA0 (non-breaking space)
\u2003 (em space)
\u200B (zero-width space)
```

## Very Long Strings
```
"A" * 256
"A" * 1024
"A" * 65536
"A" * 1048576 (1MB)
```

## Naughty Strings (Selected)

Source: Big List of Naughty Strings

```
undefined
null
NULL
(null)
nil
NIL
true
false
True
False
None
0
1
-1
1.0
-1.0
1E+02
NaN
Infinity
-Infinity
0x0
0xffffffff
```
