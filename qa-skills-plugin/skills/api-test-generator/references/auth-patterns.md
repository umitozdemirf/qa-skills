# Authentication Test Patterns

## Common Auth Schemes

### Bearer Token (JWT)

```python
# Fixture for auth headers
@pytest.fixture
def auth_headers(auth_token):
    return {"Authorization": f"Bearer {auth_token}"}

@pytest.fixture
def auth_token(base_url):
    response = httpx.post(f"{base_url}/auth/login", json={
        "username": os.environ["TEST_USER"],
        "password": os.environ["TEST_PASSWORD"],
    })
    return response.json()["access_token"]
```

**Test cases to generate:**
- Valid token: 200/2xx
- Expired token: 401
- Malformed token: 401
- Missing Authorization header: 401
- Wrong token type (e.g., "Basic" instead of "Bearer"): 401

### API Key

```python
@pytest.fixture
def api_key_headers():
    return {"X-API-Key": os.environ["TEST_API_KEY"]}
```

**Test cases to generate:**
- Valid API key: 200/2xx
- Invalid API key: 401/403
- Missing API key header: 401
- Revoked API key (if testable): 401

### OAuth2

```python
@pytest.fixture
def oauth_token(base_url):
    response = httpx.post(f"{base_url}/oauth/token", data={
        "grant_type": "client_credentials",
        "client_id": os.environ["OAUTH_CLIENT_ID"],
        "client_secret": os.environ["OAUTH_CLIENT_SECRET"],
        "scope": "read write",
    })
    return response.json()["access_token"]
```

**Test cases to generate:**
- Valid token with sufficient scope: 200
- Valid token with insufficient scope: 403
- Expired token: 401
- Invalid client credentials: 401
- Missing scope: 403

### Basic Auth

```python
import base64

@pytest.fixture
def basic_auth_headers():
    credentials = base64.b64encode(b"user:pass").decode()
    return {"Authorization": f"Basic {credentials}"}
```

**Test cases to generate:**
- Valid credentials: 200
- Invalid password: 401
- Non-existent user: 401
- Malformed Basic header: 401

## Role-Based Access Control (RBAC) Testing

```python
@pytest.fixture(params=["admin", "editor", "viewer"])
def user_role(request):
    return request.param

@pytest.fixture
def role_headers(user_role, base_url):
    token = get_token_for_role(base_url, user_role)
    return {"Authorization": f"Bearer {token}"}
```

**RBAC test matrix:**

| Endpoint | Admin | Editor | Viewer | Unauth |
|---|---|---|---|---|
| GET /resources | 200 | 200 | 200 | 401 |
| POST /resources | 201 | 201 | 403 | 401 |
| PUT /resources/:id | 200 | 200 | 403 | 401 |
| DELETE /resources/:id | 204 | 403 | 403 | 401 |

## Multi-Tenant Auth Testing

- Verify tenant isolation: User A cannot access User B's resources
- Cross-tenant request should return 403 or 404 (not 500)
- Tenant ID in URL vs header vs token claim

## Security Edge Cases

1. **Token in query string** — Should be rejected or at minimum logged as warning
2. **Concurrent token refresh** — Multiple refresh calls should not invalidate each other
3. **Token reuse after logout** — Invalidated token should return 401
4. **Case sensitivity** — "bearer" vs "Bearer" in Authorization header
5. **Empty token** — `Authorization: Bearer ` (with trailing space)
