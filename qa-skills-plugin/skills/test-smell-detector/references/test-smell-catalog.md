# Test Smell Catalog

## Assertion Smells

### No Assertion
Test body performs actions but never asserts anything. Gives false confidence.

```python
# BAD: no assertion
def test_create_user():
    client.post("/api/users", json={"name": "Test"})

# GOOD: explicit assertion
def test_create_user():
    response = client.post("/api/users", json={"name": "Test"})
    assert response.status_code == 201
    assert "id" in response.json()
```

### Redundant Assertion
Asserting a constant or trivially true value.

```python
# BAD
def test_something():
    assert True
    assert 1 == 1

# BAD: asserting the mock, not the behavior
def test_service(mocker):
    mock = mocker.patch("service.send")
    mock.return_value = "ok"
    assert mock.return_value == "ok"  # tests the mock, not the code
```

### Weak Assertion
Only checking partial information.

```python
# BAD: only checks status, not content
def test_get_user():
    response = client.get("/api/users/1")
    assert response.status_code == 200

# GOOD: checks status AND content
def test_get_user():
    response = client.get("/api/users/1")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == 1
    assert "name" in data
```

### Boolean Trap
Using truthiness instead of specific value comparison.

```python
# BAD
assert result
assert not error

# GOOD
assert result == expected_value
assert error is None
```

## Structure Smells

### Eager Test
One test verifying multiple unrelated behaviors.

```python
# BAD: tests three unrelated things
def test_user_api():
    # create
    resp = client.post("/api/users", json=data)
    assert resp.status_code == 201
    # list
    resp = client.get("/api/users")
    assert resp.status_code == 200
    # delete
    resp = client.delete(f"/api/users/{id}")
    assert resp.status_code == 204
```

Split into three focused tests.

### Mystery Guest
Test depends on external data that is not set up within the test.

```python
# BAD: depends on pre-existing DB data
def test_get_user():
    response = client.get("/api/users/42")  # who is user 42?
    assert response.status_code == 200

# GOOD: creates its own data
def test_get_user(created_user):
    response = client.get(f"/api/users/{created_user['id']}")
    assert response.status_code == 200
```

### Conditional Logic in Tests
if/else, try/catch, or loops in test body indicate the test is doing too much.

```python
# BAD
def test_results():
    response = client.get("/api/items")
    for item in response.json():
        if item["type"] == "premium":
            assert item["price"] > 100
        else:
            assert item["price"] <= 100

# GOOD: parameterize or split
@pytest.mark.parametrize("item_type,expected_min", [("premium", 101), ("basic", 0)])
def test_item_price_by_type(item_type, expected_min):
    ...
```

## Maintainability Smells

### Hardcoded Values
Magic strings and numbers scattered across tests.

```python
# BAD
response = client.post("http://localhost:8000/api/users", json={"email": "john@test.com"})

# GOOD
response = client.post(f"{base_url}/api/users", json=UserFactory.build_dict())
```

### Duplicate Tests
Near-identical tests that only differ in input values.

```python
# BAD: three separate functions
def test_short_name():
    resp = client.post("/api/users", json={"name": "a"})
    assert resp.status_code == 400

def test_empty_name():
    resp = client.post("/api/users", json={"name": ""})
    assert resp.status_code == 400

# GOOD: parameterized
@pytest.mark.parametrize("name", ["a", "", None, "x" * 256])
def test_invalid_name(name):
    resp = client.post("/api/users", json={"name": name})
    assert resp.status_code == 400
```

### Dead Tests
Tests that are skipped/disabled without documentation.

```python
# BAD: permanently skipped, no explanation
@pytest.mark.skip
def test_feature():
    ...

# ACCEPTABLE: documented reason and ticket
@pytest.mark.skip(reason="Blocked by BUG-1234, re-enable when auth service is updated")
def test_feature():
    ...
```

## Reliability Smells

### Sleep/Fixed Wait

```python
# BAD
time.sleep(3)
assert condition

# GOOD: poll or wait for condition
wait_for(lambda: check_condition(), timeout=10)
```

### Order Dependent
Tests that pass only when run in a specific order.

### Time Sensitive
Tests using real clock that fail at midnight, month boundaries, or DST.

```python
# BAD
assert result.date == datetime.now().date()

# GOOD
with freeze_time("2024-06-15"):
    assert result.date == date(2024, 6, 15)
```

## Isolation Smells

### Missing Cleanup
Tests that create resources but don't clean up.

```python
# BAD
def test_create():
    client.post("/api/items", json=data)  # leaked item

# GOOD
@pytest.fixture
def created_item(client):
    resp = client.post("/api/items", json=data)
    item = resp.json()
    yield item
    client.delete(f"/api/items/{item['id']}")
```
