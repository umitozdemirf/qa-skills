# Test Types Guide

## Test Pyramid

```
        /  E2E   \        Slow, expensive, fragile — few tests
       / Integration \    Medium speed — moderate count
      /    Unit Tests  \  Fast, cheap, stable — many tests
```

## Test Type Definitions

### Unit Tests
- **Scope**: Single function/method in isolation
- **Speed**: Milliseconds
- **Dependencies**: Mocked/stubbed
- **When**: Every code change
- **Tools**: pytest, jest, JUnit, go test

### Integration Tests
- **Scope**: Multiple components working together
- **Speed**: Seconds
- **Dependencies**: Real (DB, cache) or containerized
- **When**: API changes, service interaction changes
- **Tools**: pytest + testcontainers, supertest, REST-assured

### API/Contract Tests
- **Scope**: API endpoint behavior matches specification
- **Speed**: Seconds
- **Dependencies**: Running service
- **When**: API spec changes, new endpoints, schema changes
- **Tools**: Pact, Dredd, Schemathesis, pytest + httpx

### E2E/UI Tests
- **Scope**: Full user flow through the browser
- **Speed**: 10-60 seconds per test
- **Dependencies**: Full stack running
- **When**: UI changes, critical user flows, cross-service flows
- **Tools**: Playwright

### Performance Tests
- **Scope**: System behavior under load
- **Speed**: Minutes to hours
- **Dependencies**: Production-like environment
- **When**: New features with traffic impact, infra changes, before major releases
- **Tools**: k6, JMeter, Gatling, Locust

### Security Tests
- **Scope**: Vulnerability detection
- **Speed**: Varies (seconds to hours)
- **Dependencies**: Running service
- **When**: Auth changes, input handling changes, before releases
- **Tools**: OWASP ZAP, Burp Suite, custom scripts

### Accessibility Tests
- **Scope**: WCAG compliance
- **Speed**: Seconds
- **Dependencies**: Rendered UI
- **When**: UI component changes
- **Tools**: axe-core, Lighthouse, pa11y

### Smoke Tests
- **Scope**: Critical path sanity check
- **Speed**: Seconds
- **Dependencies**: Deployed environment
- **When**: After every deployment
- **Subset of**: E2E tests (5-10 most critical flows)

### Regression Tests
- **Scope**: Verify previously working features still work
- **Speed**: Minutes
- **Dependencies**: Varies
- **When**: Before releases, after significant changes
- **Subset of**: All test types combined

## When to Include Each Type

| Change type | Unit | Integration | API | E2E | Performance | Security |
|---|---|---|---|---|---|---|
| New function/method | Yes | Maybe | No | No | No | No |
| New API endpoint | Yes | Yes | Yes | Maybe | Maybe | Maybe |
| UI change | Maybe | No | No | Yes | No | No |
| DB schema change | Yes | Yes | Yes | Maybe | Maybe | No |
| Auth change | Yes | Yes | Yes | Yes | No | Yes |
| Config change | No | Maybe | No | Maybe | Maybe | Maybe |
| Dependency update | No | Maybe | Maybe | Maybe | Maybe | Yes |
| Performance optimization | Yes | Maybe | No | No | Yes | No |
