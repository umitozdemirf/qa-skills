# Page Object Model Guide

## Structure

```
tests/
├── e2e/
│   ├── pages/
│   │   ├── base.page.ts        # Shared methods (navigate, waitForLoad)
│   │   ├── login.page.ts       # Login page interactions
│   │   ├── dashboard.page.ts   # Dashboard page interactions
│   │   └── components/
│   │       ├── header.component.ts
│   │       └── modal.component.ts
│   ├── login.spec.ts
│   └── dashboard.spec.ts
```

## Base Page

```typescript
import { Page, Locator } from '@playwright/test'

export class BasePage {
  constructor(protected page: Page) {}

  async navigate(path: string) {
    await this.page.goto(path)
  }

  async waitForPageLoad() {
    await this.page.waitForLoadState('networkidle')
  }

  async getTitle(): Promise<string> {
    return this.page.title()
  }
}
```

## Page Object Example

```typescript
import { Page, Locator, expect } from '@playwright/test'
import { BasePage } from './base.page'

export class LoginPage extends BasePage {
  // Locators — defined once, reused across methods
  readonly emailInput: Locator
  readonly passwordInput: Locator
  readonly submitButton: Locator
  readonly errorMessage: Locator

  constructor(page: Page) {
    super(page)
    this.emailInput = page.getByTestId('login-email')
    this.passwordInput = page.getByTestId('login-password')
    this.submitButton = page.getByTestId('login-submit')
    this.errorMessage = page.getByTestId('login-error')
  }

  async goto() {
    await this.navigate('/login')
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.passwordInput.fill(password)
    await this.submitButton.click()
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toBeVisible()
    await expect(this.errorMessage).toContainText(message)
  }

  async expectRedirectToDashboard() {
    await this.page.waitForURL('**/dashboard')
  }
}
```

## Using Page Objects in Tests

```typescript
import { test, expect } from '@playwright/test'
import { LoginPage } from './pages/login.page'

test.describe('Login flow', () => {
  let loginPage: LoginPage

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page)
    await loginPage.goto()
  })

  test('should login with valid credentials', async () => {
    await loginPage.login('user@test.com', 'password123')
    await loginPage.expectRedirectToDashboard()
  })

  test('should show error for invalid credentials', async () => {
    await loginPage.login('user@test.com', 'wrong')
    await loginPage.expectError('Invalid credentials')
  })

  test('should require email field', async () => {
    await loginPage.login('', 'password123')
    await loginPage.expectError('Email is required')
  })
})
```

## Rules

1. **Page objects encapsulate interactions** — tests should not use `page.click()` directly
2. **No assertions in page objects** — except for `expect*` helper methods
3. **Locators are properties** — defined in constructor, not in methods
4. **Methods represent user actions** — `login()`, `addToCart()`, `search()`, not `clickButton()`
5. **Return page objects for navigation** — `login()` returns `DashboardPage` if it navigates

```typescript
async login(email: string, password: string): Promise<DashboardPage> {
  await this.emailInput.fill(email)
  await this.passwordInput.fill(password)
  await this.submitButton.click()
  await this.page.waitForURL('**/dashboard')
  return new DashboardPage(this.page)
}
```

6. **Components for reusable UI parts** — header, footer, modal, sidebar

```typescript
export class HeaderComponent {
  constructor(private page: Page) {}

  readonly userMenu = this.page.getByTestId('header-user-menu')
  readonly logoutButton = this.page.getByTestId('header-logout')

  async logout() {
    await this.userMenu.click()
    await this.logoutButton.click()
  }
}
```

## Anti-Patterns

- **God page object**: One POM for entire app — split by page/feature
- **Assertions everywhere**: Page objects doing assertions — keep assertions in tests
- **Selector strings in tests**: `page.click('.btn-submit')` — use page object method
- **Inheritance abuse**: Deep POM hierarchy — prefer composition over inheritance
- **Shared state**: Page objects storing test data between tests — keep tests independent
