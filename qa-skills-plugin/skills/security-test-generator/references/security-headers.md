# Security Headers Reference

## Required Headers

### Strict-Transport-Security (HSTS)
```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```
- Forces HTTPS for all future requests
- `max-age`: Duration in seconds (1 year recommended)
- `includeSubDomains`: Apply to all subdomains
- `preload`: Eligible for browser preload list

**Test**: Make HTTP request — should redirect to HTTPS. Check header present on HTTPS response.

### X-Content-Type-Options
```
X-Content-Type-Options: nosniff
```
- Prevents MIME type sniffing
- Browser won't execute files with mismatched MIME types

**Test**: Check header present. Try serving JS with text/plain content-type — browser should not execute.

### X-Frame-Options
```
X-Frame-Options: DENY
```
- Prevents clickjacking via iframes
- `DENY`: Never allow framing
- `SAMEORIGIN`: Allow same-origin framing only

**Test**: Try embedding page in iframe from different origin — should be blocked.

### Content-Security-Policy (CSP)
```
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; frame-ancestors 'none'
```
- Controls which resources the browser can load
- Most effective XSS mitigation

**Test**: Inject inline script — CSP should block execution. Check for `report-uri` or `report-to` directive.

### Referrer-Policy
```
Referrer-Policy: strict-origin-when-cross-origin
```
- Controls how much referrer info is sent
- Prevents URL leakage to third parties

### Permissions-Policy
```
Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=()
```
- Restricts browser feature access
- Empty `()` means disabled for all origins

## Recommended Headers

### Cache-Control (for sensitive pages)
```
Cache-Control: no-store, no-cache, must-revalidate
Pragma: no-cache
```
- Prevents caching of sensitive data
- Apply to auth pages, user data, admin panels

### X-XSS-Protection (Legacy)
```
X-XSS-Protection: 0
```
- Modern recommendation is to disable (set to 0) and rely on CSP
- Old browsers may have buggy XSS auditors

## CORS Headers

### Secure Configuration
```
Access-Control-Allow-Origin: https://trusted-domain.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 86400
```

### CORS Security Tests
| Test | Payload | Expected |
|---|---|---|
| Wildcard origin | Origin: https://evil.com | Should NOT reflect or use * with credentials |
| Null origin | Origin: null | Should reject |
| Subdomain bypass | Origin: https://trusted.evil.com | Should reject |
| No origin | (no Origin header) | Should still enforce on credentialed requests |

### CORS Anti-Patterns (Vulnerabilities)
```
# BAD: Reflects any origin
Access-Control-Allow-Origin: [request origin]
Access-Control-Allow-Credentials: true

# BAD: Wildcard with credentials
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true

# BAD: Null origin allowed
Access-Control-Allow-Origin: null
```

## Verification Script Pattern

```bash
# Check all security headers
URL="https://example.com"
HEADERS=$(curl -sI "$URL")

check_header() {
  local header="$1"
  if echo "$HEADERS" | grep -qi "$header"; then
    echo "PASS: $header present"
  else
    echo "FAIL: $header missing"
  fi
}

check_header "Strict-Transport-Security"
check_header "X-Content-Type-Options"
check_header "X-Frame-Options"
check_header "Content-Security-Policy"
check_header "Referrer-Policy"
check_header "Permissions-Policy"
```
