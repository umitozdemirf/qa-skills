# API Test Structure Guide

## File Organization

### By Resource (Recommended)

```
tests/
├── conftest.py              # Shared fixtures, base URL, auth
├── test_users.py            # All /api/users endpoints
├── test_products.py         # All /api/products endpoints
├── test_orders.py           # All /api/orders endpoints
├── test_auth.py             # Authentication endpoints
├── factories/
│   ├── __init__.py
│   ├── user_factory.py
│   └── product_factory.py
└── helpers/
    ├── __init__.py
    └── assertions.py        # Custom assertion helpers
```

### Test Naming Convention

```python
def test_<action>_<condition>_<expected_result>():
    """Clear docstring when test name is not self-explanatory."""
    pass

# Examples:
def test_create_user_with_valid_data_returns_201():
def test_create_user_without_email_returns_400():
def test_get_user_with_invalid_id_returns_404():
def test_delete_user_without_auth_returns_401():
def test_list_users_with_pagination_returns_correct_page():
```

## conftest.py Patterns

### Base Configuration

```python
import os
import pytest
import httpx

@pytest.fixture(scope="session")
def base_url():
    return os.environ.get("API_BASE_URL", "http://localhost:8000")

@pytest.fixture(scope="session")
def client(base_url):
    with httpx.Client(base_url=base_url, timeout=30.0) as client:
        yield client

@pytest.fixture(scope="session")
def async_client(base_url):
    async with httpx.AsyncClient(base_url=base_url, timeout=30.0) as client:
        yield client
```

### Auth Fixtures

```python
@pytest.fixture(scope="session")
def admin_token(base_url):
    resp = httpx.post(f"{base_url}/auth/login", json={
        "username": os.environ["ADMIN_USER"],
        "password": os.environ["ADMIN_PASSWORD"],
    })
    resp.raise_for_status()
    return resp.json()["access_token"]

@pytest.fixture
def admin_headers(admin_token):
    return {"Authorization": f"Bearer {admin_token}"}
```

### Cleanup Fixtures

```python
@pytest.fixture
def created_user(client, admin_headers):
    """Create a user for test, delete after."""
    payload = UserFactory.build_dict()
    resp = client.post("/api/users", json=payload, headers=admin_headers)
    user = resp.json()
    yield user
    client.delete(f"/api/users/{user['id']}", headers=admin_headers)
```

## Data Factory Patterns

### Using faker

```python
from faker import Faker

fake = Faker()

class UserFactory:
    @staticmethod
    def build_dict(**overrides):
        data = {
            "name": fake.name(),
            "email": fake.unique.email(),
            "phone": fake.phone_number(),
            "role": "viewer",
        }
        data.update(overrides)
        return data

    @staticmethod
    def build_invalid():
        return {"name": "", "email": "not-an-email"}
```

## Parameterized Tests

```python
@pytest.mark.parametrize("field,value,expected_status", [
    ("email", "", 400),
    ("email", None, 400),
    ("email", "not-an-email", 422),
    ("name", "", 400),
    ("name", "a" * 256, 400),
])
def test_create_user_validation(client, admin_headers, field, value, expected_status):
    payload = UserFactory.build_dict(**{field: value})
    response = client.post("/api/users", json=payload, headers=admin_headers)
    assert response.status_code == expected_status
```

## Response Validation Helpers

```python
def assert_pagination(response_json, expected_page=1, expected_per_page=20):
    assert "data" in response_json
    assert "meta" in response_json or "pagination" in response_json
    meta = response_json.get("meta") or response_json.get("pagination", {})
    assert meta.get("page") == expected_page
    assert meta.get("per_page") == expected_per_page
    assert "total" in meta

def assert_error_response(response, expected_status):
    assert response.status_code == expected_status
    body = response.json()
    assert any(key in body for key in ("error", "detail", "message"))
```

## Test Ordering and Independence

1. **Each test must be independent** — no test should depend on another test's side effects
2. **Use fixtures for setup/teardown** — not test ordering
3. **Use unique data per test** — faker or UUID-based identifiers
4. **Mark slow tests** — `@pytest.mark.slow` for tests hitting real external services
5. **Group by marker** — `@pytest.mark.smoke`, `@pytest.mark.regression`, `@pytest.mark.auth`

## Environment Configuration

### .env.test

```env
API_BASE_URL=http://localhost:8000
ADMIN_USER=test_admin
ADMIN_PASSWORD=test_password_123
TEST_API_KEY=test-key-xxx
OAUTH_CLIENT_ID=test-client
OAUTH_CLIENT_SECRET=test-secret
```

### pytest.ini / pyproject.toml

```toml
[tool.pytest.ini_options]
markers = [
    "smoke: quick sanity checks",
    "regression: full regression suite",
    "auth: authentication and authorization tests",
    "slow: tests requiring external services",
]
testpaths = ["tests"]
env_files = [".env.test"]
```
