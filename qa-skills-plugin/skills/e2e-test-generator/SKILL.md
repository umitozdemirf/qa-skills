---
name: e2e-test-generator
description: Generate end-to-end browser and API tests using Playwright ecosystem (Playwright Test, Playwright CLI, Playwright MCP).
---

# E2E Test Generator

Generate reliable end-to-end test suites using the Playwright ecosystem exclusively. Covers browser testing, API testing, visual regression, and component testing with proper selectors, wait strategies, and page object patterns.

## Trigger Phrases

Use this skill when the user asks for tasks like:
- "Generate E2E tests for this page"
- "Create Playwright tests for the login flow"
- "Scaffold browser tests for this app"
- "Generate UI automation tests"
- "Create smoke tests for the web app"
- "Generate Playwright API tests"
- "Set up Playwright codegen for this flow"
- "Create visual regression tests"
- "Use Playwright MCP for testing"

## Use / Do Not Use

Use this skill for:
- Generating Playwright Test browser-based E2E test files
- Playwright API testing (`request` context)
- Creating page object models from HTML/component structure
- Scaffolding Playwright configuration (playwright.config.ts)
- Generating visual regression test scaffolds
- Playwright CLI codegen workflows
- Playwright component testing setup

Do not use this skill for:
- API-only testing without browser context (use `api-test-generator`)
- Performance testing (out of scope for this skill pack today; use a dedicated performance workflow/tool)
- Analyzing existing test quality (use `test-smell-detector`)
- Non-Playwright frameworks (Selenium, Cypress, WebDriverIO) — this skill is Playwright-only

## Local Files In This Skill

- References:
  - `references/selector-strategy.md`
  - `references/wait-patterns.md`
  - `references/page-object-guide.md`
  - `references/playwright-cli-guide.md`
- Examples: `examples/`

## Deterministic Execution Flow (Required)

### 1. Discovery — Understand the Application

**Detect frontend framework:**

```bash
# Check package.json for framework
grep -E "react|vue|angular|svelte|next|nuxt|gatsby|remix|astro" package.json 2>/dev/null | head -10
```

**Detect existing Playwright setup:**

```bash
find . -maxdepth 3 -name "playwright.config.*" | head -5
```

**Check Playwright installation:**

```bash
npx playwright --version 2>/dev/null
```

**Identify target pages/flows:**

```bash
# Find route definitions
grep -rl "Route\|path:\|to=" --include="*.tsx" --include="*.jsx" --include="*.vue" --include="*.ts" --include="*.js" src/ app/ pages/ 2>/dev/null | head -20
```

If no routes are discoverable, ask the user for:
- Target URL(s)
- User flows to test (login, checkout, signup, etc.)
- Any authentication requirements

### 2. Playwright Ecosystem Selection

Always use Playwright. Determine which Playwright capabilities to leverage:

| Capability | When to use |
|---|---|
| **Playwright Test** (`@playwright/test`) | Default for all E2E tests |
| **Playwright CLI codegen** (`npx playwright codegen`) | Quick test scaffolding from user interaction |
| **Playwright API testing** (`request` context) | API calls within E2E flows (setup/teardown) |
| **Playwright Component Testing** (`@playwright/experimental-ct-*`) | Testing React/Vue/Svelte components in isolation |
| **Playwright MCP** | AI-assisted test generation and browser automation |
| **Playwright Trace Viewer** | Debugging failed tests with timeline, snapshots, network |

### 3. Load References (Only as Needed)

| Need | Read this file |
|---|---|
| Choosing selectors (data-testid vs CSS vs text) | `references/selector-strategy.md` |
| Handling async loads, navigation, animations | `references/wait-patterns.md` |
| Page object model structure | `references/page-object-guide.md` |

### 4. Generate Test Suite

For each user flow, generate:

**Required patterns:**

1. **Page Object Model** — One POM class per page/major component
2. **Happy path flow** — Complete user journey with assertions
3. **Error state tests** — Invalid inputs, network errors, empty states
4. **Navigation tests** — Links, redirects, breadcrumbs
5. **Form validation tests** — Required fields, format validation, submit behavior

**Test structure rules:**
- Use `data-testid` attributes as primary selectors (suggest adding them if missing)
- Never use fragile selectors (nth-child, complex CSS paths, XPath with indices)
- Use explicit waits — never `sleep()` or fixed timeouts
- Each test must be independent — use `beforeEach` for fresh state
- Use descriptive test names: `should <expected behavior> when <condition>`
- Include screenshot on failure configuration

**Generated file structure (Playwright):**

```
tests/
├── e2e/
│   ├── pages/
│   │   ├── login.page.ts
│   │   ├── dashboard.page.ts
│   │   └── base.page.ts
│   ├── login.spec.ts
│   ├── dashboard.spec.ts
│   └── fixtures/
│       └── auth.fixture.ts
├── playwright.config.ts
└── .env.test
```

### 5. Generate Configuration

**Playwright config essentials:**

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html'], ['list']],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
    { name: 'mobile-safari', use: { ...devices['iPhone 13'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

**Auth state persistence (storageState):**

```typescript
// tests/e2e/auth.setup.ts
import { test as setup, expect } from '@playwright/test'

setup('authenticate', async ({ page }) => {
  await page.goto('/login')
  await page.getByTestId('login-email').fill(process.env.TEST_USER!)
  await page.getByTestId('login-password').fill(process.env.TEST_PASSWORD!)
  await page.getByTestId('login-submit').click()
  await page.waitForURL('/dashboard')
  await page.context().storageState({ path: '.auth/user.json' })
})
```

**Playwright CLI quick-start commands:**

```bash
# Initialize Playwright in project
npm init playwright@latest

# Generate tests interactively
npx playwright codegen http://localhost:3000

# Run all tests
npx playwright test

# Run with UI mode (interactive debugging)
npx playwright test --ui

# Run specific test file
npx playwright test tests/e2e/login.spec.ts

# Show HTML report
npx playwright show-report

# View trace file
npx playwright show-trace trace.zip
```

### 6. Output Summary Report

```markdown
## E2E Test Generation Report

- **Framework**: Playwright Test
- **Playwright version**: <version>
- **Target app**: <URL or local path>
- **Pages/flows covered**: <count>
- **Test files generated**: <count>
- **Total test cases**: <count>

### Generated Files
| File | Flow | Test count |
|---|---|---|

### Selector Strategy
- Primary: data-testid → `page.getByTestId()`
- Fallback: role-based → `page.getByRole()`
- Avoided: CSS path, XPath indices

### Browser Coverage
- Chromium, Firefox, WebKit (desktop)
- Mobile Chrome (Pixel 5), Mobile Safari (iPhone 13)

### How to Run
\`\`\`bash
npm install
npx playwright install
npx playwright test
\`\`\`

### Useful Commands
\`\`\`bash
npx playwright test --ui          # Interactive UI mode
npx playwright codegen <url>      # Record new tests
npx playwright show-report        # View test report
npx playwright test --trace on    # Capture traces for debugging
\`\`\`

### Missing data-testid Attributes
- <list elements that need data-testid added>
```

## Fallback Behavior (Explicit)

### Fallback A: No Frontend Routes Discoverable

Action:
1. Use `npx playwright codegen <url>` to interactively discover flows
2. Ask user for target URLs and flows
3. Generate tests based on user description
4. Add TODO comments for selectors that need verification

### Fallback B: Playwright Not Installed

Action:
1. Provide installation command: `npm init playwright@latest`
2. Generate test files that will work after installation
3. Include browser install command: `npx playwright install`

### Fallback C: No data-testid Attributes in Source

Action:
1. Use `getByRole`, `getByText`, `getByLabel` as primary selectors
2. Generate a list of recommended `data-testid` additions
3. Note selector fragility in report
4. Suggest using Playwright codegen to discover reliable selectors

## Done Criteria

- Target pages/flows identified and confirmed.
- Playwright Test configured with multi-browser projects.
- Page object models generated for each page.
- Tests cover happy path, errors, navigation, and form validation.
- Selectors use resilient strategy (data-testid or role-based).
- No hardcoded waits — all Playwright auto-wait and explicit wait patterns.
- Auth state persistence configured via storageState.
- Trace and screenshot capture configured for debugging.
- Summary report with run and debug instructions provided.

## Resources

- Selector strategy: `references/selector-strategy.md`
- Wait patterns: `references/wait-patterns.md`
- Page object guide: `references/page-object-guide.md`
- Playwright CLI guide: `references/playwright-cli-guide.md`
- Examples: `examples/`

## Source Links

- [Playwright Documentation](https://playwright.dev/docs/intro)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [Playwright Test Generator (codegen)](https://playwright.dev/docs/codegen)
- [Playwright API Testing](https://playwright.dev/docs/api-testing)
- [Playwright Component Testing](https://playwright.dev/docs/test-components)
- [Playwright Trace Viewer](https://playwright.dev/docs/trace-viewer)
- [Playwright MCP Server](https://github.com/anthropics/playwright-mcp)
