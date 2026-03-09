# Example: Playwright Login Flow

## Generated files

- `tests/e2e/login.spec.ts`
- `tests/e2e/pages/LoginPage.ts`

## Example page object

```ts
import { Locator, Page, expect } from "@playwright/test"

export class LoginPage {
  readonly page: Page
  readonly emailInput: Locator
  readonly passwordInput: Locator
  readonly submitButton: Locator

  constructor(page: Page) {
    this.page = page
    this.emailInput = page.getByTestId("login-email")
    this.passwordInput = page.getByTestId("login-password")
    this.submitButton = page.getByTestId("login-submit")
  }

  async goto() {
    await this.page.goto("/login")
    await expect(this.submitButton).toBeVisible()
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.passwordInput.fill(password)
    await this.submitButton.click()
  }
}
```

## Example spec

```ts
import { test, expect } from "@playwright/test"

import { LoginPage } from "./pages/LoginPage"

test("user can sign in and reach dashboard", async ({ page }) => {
  const loginPage = new LoginPage(page)

  await loginPage.goto()
  await loginPage.login("qa@example.com", "StrongPass123!")

  await expect(page).toHaveURL(/dashboard/)
  await expect(page.getByTestId("dashboard-title")).toContainText("Dashboard")
})

test("invalid password shows inline validation", async ({ page }) => {
  const loginPage = new LoginPage(page)

  await loginPage.goto()
  await loginPage.login("qa@example.com", "wrong-password")

  await expect(page.getByTestId("login-error")).toContainText("Invalid credentials")
})
```

Notes:

- Uses `data-testid` selectors.
- Avoids fixed sleeps.
- Demonstrates POM plus happy-path and error-path coverage.
