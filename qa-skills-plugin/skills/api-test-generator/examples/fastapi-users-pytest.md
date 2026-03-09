# Example: FastAPI Users API Test Output

Source context:

- Framework: FastAPI
- Test framework: pytest
- HTTP client: httpx
- Resource: `/api/users`

Generated files:

- `tests/api/test_users_api.py`
- `tests/api/conftest.py`

Example generated test file:

```python
import pytest


@pytest.mark.anyio
async def test_list_users_returns_ok(api_client):
    response = await api_client.get("/api/users")

    assert response.status_code == 200
    payload = response.json()
    assert isinstance(payload["items"], list)


@pytest.mark.anyio
async def test_get_user_with_unknown_id_returns_not_found(api_client):
    response = await api_client.get("/api/users/999999")

    assert response.status_code == 404


@pytest.mark.anyio
async def test_create_user_without_email_returns_validation_error(api_client, auth_headers):
    response = await api_client.post(
        "/api/users",
        json={"name": "Ada Lovelace"},
        headers=auth_headers,
    )

    assert response.status_code == 422
    assert "email" in response.text


@pytest.mark.anyio
async def test_create_user_requires_authentication(api_client):
    response = await api_client.post(
        "/api/users",
        json={"email": "ada@example.com", "name": "Ada Lovelace"},
    )

    assert response.status_code == 401
```

Notes:

- Covers happy path, validation, not found, and auth.
- Matches the skill rule of grouping one resource per file.
- Uses fixtures instead of hardcoded base URL setup.
