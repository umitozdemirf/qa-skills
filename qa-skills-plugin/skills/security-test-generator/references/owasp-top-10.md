# OWASP Top 10 (2021) — Test Guide

## A01:2021 — Broken Access Control

**Description**: Users act outside their intended permissions.

**Test scenarios**:
- Access another user's data by changing ID in URL (IDOR)
- Access admin pages with regular user credentials
- Access API endpoints without authentication
- Bypass access controls by modifying tokens/cookies
- Force browsing to restricted pages
- CORS misconfiguration allowing unauthorized origins
- Missing access control on POST/PUT/DELETE methods
- Metadata manipulation (JWT, cookies, hidden fields)

**Detection commands**:
```bash
# Find endpoints without auth middleware
grep -rn "@app\.\|@router\.\|app\.\(get\|post\|put\|delete\)" --include="*.py" | grep -v "auth\|login\|public\|health"
```

## A02:2021 — Cryptographic Failures

**Test scenarios**:
- Sensitive data transmitted over HTTP (not HTTPS)
- Weak hashing algorithms (MD5, SHA1) for passwords
- Hardcoded encryption keys/secrets
- Missing encryption at rest for sensitive data
- Weak TLS configuration
- Sensitive data in URL parameters (logged by proxies)

## A03:2021 — Injection

**Test scenarios**:
- SQL injection in all user inputs
- NoSQL injection (MongoDB operators)
- OS command injection
- LDAP injection
- Template injection (SSTI)
- XSS (stored, reflected, DOM-based)
- Header injection (CRLF)
- XML/XXE injection

**Detection commands**:
```bash
# Find raw SQL queries
grep -rn "execute\|cursor\|raw_sql\|text(" --include="*.py" | grep -v "test\|migration"
# Find template rendering
grep -rn "render_template_string\|Markup\|mark_safe\|dangerouslySetInnerHTML\|v-html" --include="*.py" --include="*.js" --include="*.tsx"
```

## A04:2021 — Insecure Design

**Test scenarios**:
- Missing rate limiting on sensitive operations
- No CAPTCHA on login/registration
- Business logic flaws (negative quantities, price manipulation)
- Missing server-side validation (client-only validation)
- Insecure password recovery flow
- Missing re-authentication for sensitive operations

## A05:2021 — Security Misconfiguration

**Test scenarios**:
- Default credentials active
- Unnecessary features enabled (directory listing, debug mode)
- Missing security headers
- Verbose error messages exposing internals
- Outdated software versions
- CORS wildcard or overly permissive
- Debug/admin endpoints accessible

**Security headers to check**:
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Content-Security-Policy: default-src 'self'
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=()
```

## A06:2021 — Vulnerable and Outdated Components

**Test scenarios**:
- Known CVEs in dependencies
- Outdated framework versions
- Unused dependencies (wider attack surface)

**Detection commands**:
```bash
# Python
pip audit
safety check

# JavaScript
npm audit
npx auditjs

# Java
mvn dependency-check:check
```

## A07:2021 — Identification and Authentication Failures

**Test scenarios**:
- Brute force login (no rate limiting/lockout)
- Credential stuffing
- Weak password policy
- Session fixation
- Session not invalidated on logout
- Missing MFA for sensitive operations
- Predictable session IDs

## A08:2021 — Software and Data Integrity Failures

**Test scenarios**:
- Insecure deserialization
- CI/CD pipeline integrity
- Auto-update without integrity verification
- Unsigned packages/artifacts

## A09:2021 — Security Logging and Monitoring Failures

**Test scenarios**:
- Failed login attempts not logged
- High-value transactions not logged
- Logs not protected from tampering
- No alerting for suspicious activity
- Sensitive data in logs (passwords, tokens)

## A10:2021 — Server-Side Request Forgery (SSRF)

**Test scenarios**:
- URL parameters fetching internal resources
- Redirect to internal services (127.0.0.1, 169.254.169.254)
- Protocol smuggling (file://, gopher://)
- DNS rebinding
- Bypass via URL encoding, IP formats
