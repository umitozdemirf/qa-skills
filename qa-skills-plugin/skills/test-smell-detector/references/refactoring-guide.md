# Test Refactoring Guide

## Priority Order

1. Fix false-confidence tests (no assertions, redundant assertions) — Critical
2. Fix flaky tests (sleep waits, shared state, external deps) — High
3. Consolidate duplicate tests into parameterized — Medium
4. Improve naming and structure — Low

## Refactoring Patterns

### No Assertion → Add Meaningful Assert

```python
# Before
def test_create_user(client):
    client.post("/api/users", json=data)

# After
def test_create_user(client):
    response = client.post("/api/users", json=data)
    assert response.status_code == 201
    user = response.json()
    assert user["name"] == data["name"]
    assert "id" in user
```

### Hardcoded Values → Fixtures/Factories

```python
# Before
def test_create_user(client):
    response = client.post("http://localhost:8000/api/users", json={
        "name": "John Doe",
        "email": "john@example.com"
    })

# After
def test_create_user(client, user_payload):
    response = client.post("/api/users", json=user_payload)
```

### Duplicate Tests → Parameterized

```python
# Before: 5 separate test functions with same structure

# After
@pytest.mark.parametrize("invalid_email", [
    "",
    "not-an-email",
    "@missing-local.com",
    "missing-domain@",
    "spaces in@email.com",
])
def test_reject_invalid_email(client, auth_headers, invalid_email):
    response = client.post("/api/users", json={"email": invalid_email}, headers=auth_headers)
    assert response.status_code in (400, 422)
```

### Sleep → Explicit Wait

```python
# Before
time.sleep(5)
assert status == "complete"

# After
import tenacity

@tenacity.retry(stop=tenacity.stop_after_delay(10), wait=tenacity.wait_fixed(0.5))
def wait_for_completion():
    status = get_status()
    assert status == "complete"

wait_for_completion()
```

### External Dependency → Mock

```python
# Before: calls real Stripe API
def test_payment(client):
    response = client.post("/api/payments", json=payment_data)
    assert response.status_code == 200

# After: mocked
def test_payment(client, mocker):
    mocker.patch("services.stripe.create_charge", return_value={"id": "ch_test", "status": "succeeded"})
    response = client.post("/api/payments", json=payment_data)
    assert response.status_code == 200
```

### Eager Test → Focused Tests

Split a test verifying 5 behaviors into 5 focused tests, each with:
- One setup
- One action
- One or more related assertions
- Descriptive name

### Missing Cleanup → Fixture with Teardown

```python
# Before: leaks data
def test_create_and_verify(client):
    resp = client.post("/api/items", json=data)
    item_id = resp.json()["id"]
    resp = client.get(f"/api/items/{item_id}")
    assert resp.status_code == 200

# After: cleanup guaranteed
@pytest.fixture
def created_item(client, auth_headers):
    resp = client.post("/api/items", json=data, headers=auth_headers)
    item = resp.json()
    yield item
    client.delete(f"/api/items/{item['id']}", headers=auth_headers)

def test_get_created_item(client, auth_headers, created_item):
    resp = client.get(f"/api/items/{created_item['id']}", headers=auth_headers)
    assert resp.status_code == 200
```

## Verification After Refactoring

After each refactoring batch:
1. Run the test suite — all tests must pass
2. Verify no new failures introduced
3. Check that refactored tests still detect the bug they were written for
4. Confirm test count is same or fewer (consolidation is OK)
