# Wait Patterns Guide

## Golden Rule

**Never use fixed waits (sleep/setTimeout).** Always wait for a specific condition.

## Playwright Wait Patterns

### Auto-Waiting (Default)

Playwright auto-waits for elements to be actionable before performing actions:

```typescript
// These auto-wait — no explicit wait needed
await page.click('[data-testid="submit"]')
await page.fill('[data-testid="email"]', 'user@test.com')
await page.getByRole('button', { name: 'Submit' }).click()
```

### Explicit Waits

```typescript
// Wait for element to be visible
await page.getByTestId('loading-spinner').waitFor({ state: 'hidden' })
await page.getByTestId('results').waitFor({ state: 'visible' })

// Wait for navigation
await Promise.all([
  page.waitForNavigation(),
  page.click('[data-testid="nav-link"]'),
])

// Wait for network response
const responsePromise = page.waitForResponse('**/api/users')
await page.click('[data-testid="load-users"]')
const response = await responsePromise

// Wait for URL change
await page.waitForURL('**/dashboard')

// Wait for element count
await expect(page.getByTestId('list-item')).toHaveCount(5)
```

### Assertion-Based Waiting

```typescript
// expect() auto-retries until timeout
await expect(page.getByTestId('status')).toHaveText('Complete')
await expect(page.getByTestId('modal')).toBeVisible()
await expect(page.getByTestId('error')).not.toBeVisible()
```

## Route Interception (API Mocking)

```typescript
// Mock API response
await page.route('**/api/users', async (route) => {
  await route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify([{ id: 1, name: 'Test User' }]),
  })
})

// Wait for specific API call
const responsePromise = page.waitForResponse(
  (response) => response.url().includes('/api/users') && response.status() === 200
)
await page.getByTestId('refresh').click()
const response = await responsePromise
const data = await response.json()
```

## Common Anti-Patterns

### Fixed Sleep (Never Do This)

```typescript
// BAD
await page.waitForTimeout(3000)
await new Promise(r => setTimeout(r, 2000))
```

### Why Fixed Waits Are Bad
- Too short: flaky on slow CI/environments
- Too long: waste time on every run
- Non-deterministic: no guarantee the condition is met

### Correct Alternatives

| Instead of | Use |
|---|---|
| `sleep(2000)` after button click | `waitForNavigation()` or `waitForURL()` |
| `sleep(3000)` for API response | `waitForResponse()` or network intercept |
| `sleep(1000)` for animation | `waitFor({ state: 'visible' })` on target element |
| `sleep(5000)` for page load | `waitForLoadState('networkidle')` |
| `sleep(500)` for element render | Auto-waiting or `expect().toBeVisible()` |

## Timeout Configuration

```typescript
// playwright.config.ts
export default defineConfig({
  timeout: 30_000,           // test timeout
  expect: { timeout: 5_000 }, // assertion timeout
  use: {
    actionTimeout: 10_000,   // click/fill timeout
    navigationTimeout: 15_000,
  },
})
```

Set timeouts appropriate for environment:
- Local: shorter (5-10s)
- CI: longer (15-30s)
- Never: > 60s for a single wait (indicates a problem)
