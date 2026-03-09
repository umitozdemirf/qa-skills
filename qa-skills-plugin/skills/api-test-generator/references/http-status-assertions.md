# HTTP Status Code Assertion Patterns

## 2xx Success

### 200 OK
- GET requests returning data
- Assertions: status code, response body structure, content-type header

```python
# pytest + httpx
response = client.get("/api/users/1")
assert response.status_code == 200
assert "id" in response.json()
assert response.headers["content-type"] == "application/json"
```

### 201 Created
- POST requests creating resources
- Assertions: status code, Location header, created resource in body

```python
response = client.post("/api/users", json=payload)
assert response.status_code == 201
assert "id" in response.json()
assert response.headers.get("location") is not None
```

### 204 No Content
- DELETE or PUT requests with no response body
- Assertions: status code, empty body

```python
response = client.delete(f"/api/users/{user_id}")
assert response.status_code == 204
assert response.content == b""
```

## 4xx Client Errors

### 400 Bad Request
- Invalid input, malformed JSON, missing required fields
- Assertions: status code, error message structure

```python
response = client.post("/api/users", json={})
assert response.status_code == 400
error = response.json()
assert "error" in error or "detail" in error or "message" in error
```

### 401 Unauthorized
- Missing or invalid authentication
- Assertions: status code, WWW-Authenticate header (optional)

```python
response = client.get("/api/users", headers={})
assert response.status_code == 401
```

### 403 Forbidden
- Valid auth but insufficient permissions
- Assertions: status code, error message

```python
response = client.delete("/api/admin/users/1", headers=regular_user_headers)
assert response.status_code == 403
```

### 404 Not Found
- Non-existent resource or invalid path
- Assertions: status code

```python
response = client.get("/api/users/99999999")
assert response.status_code == 404
```

### 409 Conflict
- Duplicate resource creation, version conflicts
- Assertions: status code, conflict details

```python
response = client.post("/api/users", json=duplicate_payload)
assert response.status_code == 409
```

### 422 Unprocessable Entity
- Valid JSON but semantic validation failure
- Assertions: status code, validation error details

```python
response = client.post("/api/users", json={"email": "not-an-email"})
assert response.status_code == 422
errors = response.json()
assert any("email" in str(e) for e in errors.get("detail", []))
```

### 429 Too Many Requests
- Rate limit exceeded
- Assertions: status code, Retry-After header

```python
# Rapid-fire requests
for _ in range(100):
    response = client.get("/api/resource")
assert response.status_code == 429
assert "retry-after" in response.headers
```

## 5xx Server Errors

### 500 Internal Server Error
- Should generally NOT be expected in tests
- If testing error handling: verify graceful degradation

### 502 Bad Gateway / 503 Service Unavailable
- External dependency failures
- Test with mocked/stubbed downstream services

## Assertion Best Practices

1. **Always assert status code first** — it determines which other assertions are valid
2. **Assert response structure, not exact values** — unless testing specific data
3. **Assert content-type header** — prevents silent format changes
4. **Assert error message format consistency** — all errors should follow same schema
5. **Use response time assertions sparingly** — only when SLA requirements exist
6. **Assert pagination metadata** — total count, page number, has_next
7. **Assert idempotency** — repeated PUT/DELETE should return same status
