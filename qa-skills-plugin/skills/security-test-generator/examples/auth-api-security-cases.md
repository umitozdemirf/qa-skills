# Example: Auth API Security Test Cases

Target:

- Service: `POST /api/auth/login`, `POST /api/auth/refresh`, `GET /api/users/{id}`
- Auth: JWT bearer tokens
- Risk areas: broken access control, auth failures, misconfiguration

Generated cases:

## A01 - Broken Access Control

- Attempt `GET /api/users/2002` with a valid token for user `1001`
  - Expected: `403` or `404`
- Attempt `GET /api/admin/audit-log` with a regular user token
  - Expected: `403`
- Attempt `PUT /api/users/1001/role` with a manager token lacking admin scope
  - Expected: `403`

## A07 - Authentication Failures

- Submit 20 invalid passwords for the same account within 60 seconds
  - Expected: rate limit, temporary lockout, or equivalent protection
- Reuse refresh token after rotation
  - Expected: second refresh attempt rejected
- Call `POST /api/auth/refresh` with an expired token
  - Expected: `401`
- Call `POST /api/auth/login` with common password `Password123!`
  - Expected: rejected if password policy is enforced at creation/reset time

## A05 - Security Misconfiguration

- Send request without `Origin` and with `Origin: https://evil.example`
  - Expected: no wildcard reflection for credentialed requests
- Verify response headers:
  - `Strict-Transport-Security`
  - `X-Content-Type-Options: nosniff`
  - `Content-Security-Policy`
- Trigger an auth error with malformed JWT
  - Expected: generic error without stack trace or secret leakage

## Example pytest snippets

```python
def test_user_cannot_access_another_users_profile(client, user_a_headers):
    response = client.get("/api/users/2002", headers=user_a_headers)
    assert response.status_code in (403, 404)


def test_reused_refresh_token_is_rejected(client, refresh_token):
    first = client.post("/api/auth/refresh", json={"refresh_token": refresh_token})
    second = client.post("/api/auth/refresh", json={"refresh_token": refresh_token})

    assert first.status_code == 200
    assert second.status_code == 401
```
