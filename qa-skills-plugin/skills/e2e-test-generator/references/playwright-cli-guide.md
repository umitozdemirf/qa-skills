# Playwright CLI and Ecosystem Guide

## Playwright CLI Commands

### Project Setup

```bash
# Initialize new Playwright project (interactive wizard)
npm init playwright@latest

# Install browsers
npx playwright install

# Install specific browser
npx playwright install chromium
npx playwright install firefox
npx playwright install webkit

# Install system dependencies (Linux CI)
npx playwright install-deps
```

### Test Execution

```bash
# Run all tests
npx playwright test

# Run specific file
npx playwright test tests/e2e/login.spec.ts

# Run tests matching grep pattern
npx playwright test --grep "login"
npx playwright test --grep-invert "slow"

# Run specific project (browser)
npx playwright test --project=chromium

# Run in headed mode (see the browser)
npx playwright test --headed

# Run with specific workers
npx playwright test --workers=4

# Run a single test by line number
npx playwright test tests/e2e/login.spec.ts:15

# Fail fast — stop on first failure
npx playwright test --max-failures=1
```

### Interactive Modes

```bash
# UI Mode — interactive test runner with watch mode
npx playwright test --ui

# Debug Mode — step through tests with Playwright Inspector
npx playwright test --debug

# Debug specific test
npx playwright test tests/e2e/login.spec.ts --debug
```

### Code Generation (codegen)

```bash
# Record interactions and generate test code
npx playwright codegen https://example.com

# Record with specific viewport
npx playwright codegen --viewport-size=1280,720 https://example.com

# Record with specific device emulation
npx playwright codegen --device="iPhone 13" https://example.com

# Record with color scheme
npx playwright codegen --color-scheme=dark https://example.com

# Save generated code to file
npx playwright codegen --output=tests/e2e/recorded.spec.ts https://example.com

# Record with authentication state
npx playwright codegen --load-storage=.auth/user.json https://example.com
```

### Reporting and Debugging

```bash
# Show HTML report
npx playwright show-report

# View trace file
npx playwright show-trace trace.zip

# Generate traces for all tests
npx playwright test --trace on

# Generate traces only for failures
npx playwright test --trace retain-on-failure

# Screenshot on failure (configured in playwright.config.ts)
npx playwright test --screenshot only-on-failure

# Record video
npx playwright test --video on
```

## Playwright Test Configuration Patterns

### Global Setup and Teardown

```typescript
// playwright.config.ts
export default defineConfig({
  globalSetup: require.resolve('./global-setup'),
  globalTeardown: require.resolve('./global-teardown'),
})
```

### Authentication Setup Project

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    // Setup project — runs first
    { name: 'setup', testMatch: /.*\.setup\.ts/ },

    // Browser projects — depend on setup
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        storageState: '.auth/user.json',
      },
      dependencies: ['setup'],
    },
  ],
})
```

### Environment-Specific Configuration

```typescript
// playwright.config.ts
const isCI = !!process.env.CI

export default defineConfig({
  retries: isCI ? 2 : 0,
  workers: isCI ? 1 : undefined,
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: isCI ? 'retain-on-failure' : 'on-first-retry',
    video: isCI ? 'retain-on-failure' : 'off',
  },
})
```

## Playwright API Testing

Playwright can also test APIs directly without a browser:

```typescript
import { test, expect } from '@playwright/test'

test.describe('API tests', () => {
  test('GET /api/users returns list', async ({ request }) => {
    const response = await request.get('/api/users')
    expect(response.ok()).toBeTruthy()
    const users = await response.json()
    expect(users.length).toBeGreaterThan(0)
  })

  test('POST /api/users creates user', async ({ request }) => {
    const response = await request.post('/api/users', {
      data: { name: 'Test User', email: 'test@example.com' },
    })
    expect(response.status()).toBe(201)
    const user = await response.json()
    expect(user.name).toBe('Test User')
  })
})
```

**Use Playwright API testing for:**
- Setup/teardown within E2E tests (create data via API, test via browser)
- Mixed API+browser test scenarios
- Quick API smoke tests in the same project

**Use `api-test-generator` skill for:**
- Dedicated, comprehensive API test suites
- Tests using native framework features (pytest fixtures, JUnit parameterized)

## Playwright MCP (Model Context Protocol)

Playwright MCP server enables AI-assisted browser automation:

```bash
# Install Playwright MCP
npx @anthropic-ai/playwright-mcp
```

**Capabilities:**
- AI agent navigates and interacts with web pages
- Automated test generation from natural language descriptions
- Browser state observation and assertion generation
- Screenshot capture and visual comparison

**Use cases:**
- Exploratory testing with AI assistance
- Test generation from user stories
- Visual regression detection
- Accessibility testing automation

## Playwright Component Testing

Test framework components in isolation (experimental):

```bash
# Install for React
npm install -D @playwright/experimental-ct-react
```

```typescript
// Button.spec.tsx
import { test, expect } from '@playwright/experimental-ct-react'
import { Button } from './Button'

test('renders with text', async ({ mount }) => {
  const component = await mount(<Button>Click me</Button>)
  await expect(component).toContainText('Click me')
})

test('handles click', async ({ mount }) => {
  let clicked = false
  const component = await mount(
    <Button onClick={() => (clicked = true)}>Click me</Button>
  )
  await component.click()
  expect(clicked).toBe(true)
})
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Playwright Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test
      - uses: actions/upload-artifact@v4
        if: ${{ !cancelled() }}
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```
