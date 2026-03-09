# Authentication & Authorization Security Checklist

## Authentication Tests

### Login Endpoint
- [ ] Brute force protection: Account lockout or rate limiting after N failed attempts
- [ ] Generic error messages: "Invalid credentials" (not "User not found" or "Wrong password")
- [ ] Timing attack resistance: Same response time for valid/invalid usernames
- [ ] HTTPS only: Login endpoint rejects or redirects HTTP
- [ ] Password not logged: Check server logs don't contain passwords
- [ ] SQL injection in login fields
- [ ] Case sensitivity: username/email handling

### Password Policy
- [ ] Minimum length enforced (8+ recommended, 12+ ideal)
- [ ] Maximum length allowed (at least 64-128 chars)
- [ ] Common password rejection (top 10K list)
- [ ] No character type restrictions that reduce entropy
- [ ] Bcrypt/Argon2/scrypt used for hashing (not MD5/SHA1/SHA256)

### Session Management
- [ ] Session ID regenerated after login (prevent fixation)
- [ ] Session invalidated on logout
- [ ] Session timeout enforced (idle and absolute)
- [ ] Session ID not in URL (cookie only)
- [ ] Cookie flags: HttpOnly, Secure, SameSite
- [ ] Concurrent session handling (limit or notify)

### Token Security (JWT)
- [ ] Algorithm explicitly set (reject `alg: none`)
- [ ] Token expiry enforced (short-lived access tokens)
- [ ] Refresh token rotation
- [ ] Token cannot be used after logout (blacklist/rotation)
- [ ] Signature verified on every request
- [ ] Sensitive data not in JWT payload (it's base64, not encrypted)
- [ ] Token transmitted via header, not URL

### Password Reset
- [ ] Token is single-use
- [ ] Token expires (15-60 minutes)
- [ ] Token is random and unguessable
- [ ] Old password not required (user might not know it)
- [ ] Account confirmation after reset
- [ ] Rate limiting on reset requests

### MFA (if applicable)
- [ ] MFA cannot be bypassed by directly calling post-MFA endpoints
- [ ] MFA code rate limited
- [ ] MFA code expires quickly (30-60 seconds for TOTP)
- [ ] Backup codes are single-use
- [ ] MFA required for sensitive operations (not just login)

## Authorization Tests

### RBAC
- [ ] Each role can only access permitted endpoints
- [ ] Role check on every request (not just UI-level hiding)
- [ ] Cannot escalate own role via API
- [ ] Admin functions inaccessible to regular users

### Resource-Level Access
- [ ] Users can only access their own resources (IDOR check)
- [ ] Cannot access resources by guessing/incrementing IDs
- [ ] Deleted/suspended user's token is rejected
- [ ] Cross-tenant isolation (multi-tenant apps)

### API Authorization
- [ ] Every endpoint has explicit auth requirement
- [ ] Public endpoints are intentionally public (whitelist approach)
- [ ] GraphQL: Authorize per field/resolver, not just per query
- [ ] Batch/bulk endpoints respect per-resource authorization
- [ ] File download/upload endpoints check ownership

## Test Matrix Template

| Test | Login | Signup | Profile | Admin | Public |
|---|---|---|---|---|---|
| No auth | 200 | 200 | 401 | 401 | 200 |
| Valid user | 200 | 200 | 200 | 403 | 200 |
| Admin | 200 | 200 | 200 | 200 | 200 |
| Expired token | 401 | 401 | 401 | 401 | 200 |
| Invalid token | 401 | 401 | 401 | 401 | 200 |
| Other user's resource | — | — | 403/404 | 200 | — |
