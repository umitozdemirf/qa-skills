---
name: security-test-generator
description: Generate OWASP-based security test cases for web applications and APIs.
---

# Security Test Generator

Generate security-focused test cases based on OWASP Top 10 and common vulnerability patterns. Covers injection, authentication, authorization, data exposure, and configuration security.

## Trigger Phrases

Use this skill when the user asks for tasks like:
- "Generate security tests for this API"
- "Create OWASP test cases for this app"
- "Test for SQL injection vulnerabilities"
- "Generate XSS test cases"
- "Security test this authentication flow"
- "Check for IDOR vulnerabilities"
- "Create penetration test cases"

## Use / Do Not Use

Use this skill for:
- Generating security test cases and payloads for authorized testing
- OWASP Top 10 coverage verification
- Auth/authz security test scenarios
- Input sanitization verification tests
- Security header and configuration checks
- CSRF, CORS, and session security tests

Do not use this skill for:
- General input validation (use `input-validation-tester`)
- Running actual security scanners or exploitation tools
- Generating tests for unauthorized systems
- Full penetration testing (this generates test cases, not exploitation)

## Local Files In This Skill

- References:
  - `references/owasp-top-10.md`
  - `references/injection-payloads.md`
  - `references/auth-security-checklist.md`
  - `references/security-headers.md`

## Deterministic Execution Flow (Required)

### 1. Discovery — Understand Attack Surface

**Identify application type:**

```bash
# Detect web framework
grep -rl "FastAPI\|flask\|Django\|express\|Spring\|Rails\|NestJS\|Laravel" --include="*.py" --include="*.js" --include="*.ts" --include="*.java" --include="*.rb" --include="*.php" . 2>/dev/null | head -10

# Detect auth implementation
grep -rl "jwt\|oauth\|session\|cookie\|bearer\|passport\|auth" --include="*.py" --include="*.js" --include="*.ts" --include="*.java" . 2>/dev/null | head -15

# Detect database usage
grep -rl "SELECT\|INSERT\|UPDATE\|DELETE\|query\|execute\|cursor\|ORM\|prisma\|sequelize\|sqlalchemy\|typeorm" --include="*.py" --include="*.js" --include="*.ts" --include="*.java" . 2>/dev/null | head -15
```

**Map the attack surface:**
- User input points (forms, API params, headers, cookies, file uploads)
- Authentication mechanisms
- Authorization model (RBAC, ABAC, resource-based)
- Data storage (SQL, NoSQL, file system)
- External integrations
- File upload/download functionality

### 2. Select OWASP Categories

Based on discovery, determine applicable OWASP Top 10 (2021) categories:

| # | Category | Include when |
|---|---|---|
| A01 | Broken Access Control | Any auth/authz exists |
| A02 | Cryptographic Failures | Sensitive data handling, passwords, tokens |
| A03 | Injection | Any database queries, OS commands, LDAP, template engines |
| A04 | Insecure Design | Business logic, multi-step flows |
| A05 | Security Misconfiguration | Any deployment, headers, CORS, error handling |
| A06 | Vulnerable Components | Third-party dependencies |
| A07 | Auth Failures | Login, registration, session management |
| A08 | Software/Data Integrity | Deserialization, CI/CD, unsigned updates |
| A09 | Logging Failures | Audit logging, monitoring |
| A10 | SSRF | URL parameters, webhooks, external fetches |

### 3. Load References (Only as Needed)

| Need | Read this file |
|---|---|
| OWASP category details | `references/owasp-top-10.md` |
| Injection test payloads | `references/injection-payloads.md` |
| Auth security patterns | `references/auth-security-checklist.md` |
| Header/config checks | `references/security-headers.md` |

### 4. Generate Security Test Cases

#### A01: Broken Access Control

```markdown
- IDOR: Access resource with another user's ID
  - GET /api/users/{other_user_id} with valid auth
  - GET /api/orders/{other_user_order_id} with valid auth
- Privilege escalation: Regular user accessing admin endpoints
  - POST /api/admin/users with regular user token
  - PUT /api/users/{id}/role with regular user token
- Missing auth: Access protected endpoint without token
- Force browsing: Access direct URLs to resources without navigation
- Method override: Try PUT/DELETE on read-only endpoints
- Path traversal: /api/users/../admin/config
```

#### A03: Injection

```markdown
- SQL injection (if SQL detected):
  - String params: `' OR '1'='1`, `'; DROP TABLE users--`, `' UNION SELECT null,null--`
  - Numeric params: `1 OR 1=1`, `1; DROP TABLE users`
  - Order by: `name ASC; DROP TABLE users--`
- NoSQL injection (if MongoDB/similar detected):
  - `{"$gt": ""}`, `{"$ne": null}`, `{"$regex": ".*"}`
- Command injection (if OS commands used):
  - `; ls -la`, `| cat /etc/passwd`, `$(whoami)`, `` `id` ``
- Template injection:
  - `{{7*7}}`, `${7*7}`, `<%= 7*7 %>`, `#{7*7}`
- XSS (if HTML rendering):
  - `<script>alert(1)</script>`
  - `<img src=x onerror=alert(1)>`
  - `javascript:alert(1)`
  - Event handlers: `" onmouseover="alert(1)`
```

#### A05: Security Misconfiguration

```markdown
- Security headers check:
  - Strict-Transport-Security present
  - X-Content-Type-Options: nosniff
  - X-Frame-Options: DENY or SAMEORIGIN
  - Content-Security-Policy present
  - X-XSS-Protection (legacy but check)
- CORS misconfiguration:
  - Origin: null (should be rejected)
  - Origin: https://evil.com (should not be reflected)
  - Origin: https://trusted-domain.evil.com (subdomain bypass)
- Error handling:
  - Stack traces not exposed in production errors
  - Verbose error messages don't leak internals
- Default credentials check
- Debug endpoints exposed (/debug, /actuator, /swagger, /__debug__)
```

#### A07: Authentication Failures

```markdown
- Brute force: Rapid login attempts (check for rate limiting)
- Credential stuffing: Valid username, common passwords
- Password policy:
  - Short password (1 char)
  - Common password ("password123")
  - No complexity requirement
- Session management:
  - Session fixation (reuse session ID after login)
  - Session not invalidated after logout
  - Session timeout too long
- Token security:
  - JWT with alg:none
  - JWT with weak secret (brute-forceable)
  - Token not expiring
  - Refresh token rotation
- MFA bypass (if MFA exists):
  - Skip MFA step by directly calling post-MFA endpoint
  - Reuse MFA code
```

### 5. Generate Test Code (When Requested)

```python
import pytest
import httpx

class TestBrokenAccessControl:
    """A01: Broken Access Control tests."""

    def test_idor_user_cannot_access_other_user_data(self, client, user_a_headers, user_b_id):
        """Verify user A cannot access user B's data."""
        response = client.get(f"/api/users/{user_b_id}", headers=user_a_headers)
        assert response.status_code in (403, 404), \
            f"IDOR vulnerability: user accessed another user's data (got {response.status_code})"

    def test_regular_user_cannot_access_admin_endpoint(self, client, regular_user_headers):
        """Verify regular user cannot access admin endpoints."""
        response = client.get("/api/admin/users", headers=regular_user_headers)
        assert response.status_code == 403

    def test_unauthenticated_access_returns_401(self, client):
        """Verify protected endpoint requires authentication."""
        response = client.get("/api/users/me")
        assert response.status_code == 401


class TestInjection:
    """A03: Injection tests."""

    @pytest.mark.parametrize("payload", [
        "' OR '1'='1",
        "'; DROP TABLE users--",
        "' UNION SELECT null,null--",
        "1 OR 1=1",
    ])
    def test_sql_injection_in_search(self, client, auth_headers, payload):
        """Verify SQL injection payloads are rejected or sanitized."""
        response = client.get(f"/api/search?q={payload}", headers=auth_headers)
        assert response.status_code in (200, 400), \
            f"Unexpected status {response.status_code} for SQLi payload"
        if response.status_code == 200:
            # Should return empty or normal results, not all records
            data = response.json()
            assert len(data.get("results", [])) < 100, \
                "Possible SQLi: returned suspiciously many results"
```

### 6. Output Summary Report

```markdown
## Security Test Generation Report

- **Target**: <app/service>
- **Attack surface**: <endpoints, auth, DB, file upload, etc.>
- **OWASP categories covered**: <list>
- **Test cases generated**: <count>

### Coverage by OWASP Category
| Category | Test cases | Applicable |
|---|---|---|
| A01: Broken Access Control | <n> | <yes/no/partial> |
| A02: Cryptographic Failures | <n> | <yes/no/partial> |
| A03: Injection | <n> | <yes/no/partial> |
| ... | ... | ... |

### Critical Test Cases (Must Run)
1. <most important security tests>

### Test Data / Payloads Used
- <summary of payload categories>

### How to Run
\`\`\`bash
<command>
\`\`\`

### Limitations
- <what this does NOT cover (e.g., binary exploitation, network-level attacks)>
```

## Fallback Behavior (Explicit)

### Fallback A: Cannot Determine Tech Stack

Action:
1. Generate framework-agnostic security checklist
2. Focus on HTTP-level tests (headers, CORS, auth)
3. Ask user for tech stack details

### Fallback B: No Authentication in Application

Action:
1. Skip A01 and A07 categories
2. Focus on injection, misconfiguration, and data exposure
3. Note that missing auth is itself a finding

## Done Criteria

- Attack surface mapped.
- Applicable OWASP categories identified.
- Test cases generated per category.
- Test payloads are safe for authorized testing (no destructive payloads).
- Summary report with coverage matrix provided.
- Limitations clearly stated.

## Resources

- OWASP Top 10: `references/owasp-top-10.md`
- Injection payloads: `references/injection-payloads.md`
- Auth checklist: `references/auth-security-checklist.md`
- Security headers: `references/security-headers.md`

## Source Links

- [OWASP Top 10 (2021)](https://owasp.org/Top10/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [HackTricks](https://book.hacktricks.wiki/)
