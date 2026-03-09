# Selector Strategy Guide

## Priority Order (Most to Least Reliable)

### 1. data-testid (Recommended Primary)

```html
<button data-testid="submit-order">Place Order</button>
```

```typescript
page.getByTestId('submit-order')
```

**Pros**: Stable, decoupled from styling/content, explicit testing intent
**Cons**: Requires adding attributes to source code

### 2. Role-Based (Accessible Selectors)

```typescript
page.getByRole('button', { name: 'Place Order' })
page.getByRole('heading', { level: 1 })
page.getByRole('textbox', { name: 'Email' })
page.getByRole('link', { name: 'Sign up' })
```

**Pros**: Resilient to implementation changes, tests accessibility
**Cons**: Can be ambiguous with similar labels

### 3. Label/Placeholder Text

```typescript
page.getByLabel('Email address')
page.getByPlaceholder('Enter your email')
```

**Pros**: Matches user perspective
**Cons**: Breaks when text changes, not usable for all elements

### 4. Text Content

```typescript
page.getByText('Welcome back')
page.getByText(/total: \$\d+/)
```

**Pros**: Human-readable tests
**Cons**: Fragile with text changes, i18n breaks everything

### 5. CSS Selectors (Last Resort)

```typescript
page.locator('.submit-btn')
page.locator('#checkout-form')
```

**Pros**: Familiar syntax
**Cons**: Coupled to styling, breaks with redesigns

## Anti-Patterns (Never Use)

```typescript
// XPath with indices
page.locator('//div[3]/ul/li[2]/a')

// Complex CSS paths
page.locator('div.container > div:nth-child(3) > ul > li:nth-child(2)')

// Auto-generated class names
page.locator('.css-1a2b3c')
page.locator('[class*="styled__Button"]')

// Positional selectors without context
page.locator('button').nth(3)
```

## Naming Conventions for data-testid

```
<component>-<element>[-<modifier>]

Examples:
- login-form
- login-email-input
- login-submit-button
- user-menu-dropdown
- product-card-add-to-cart
- checkout-total-price
- error-message-email
```

## Playwright Locator Methods

### Built-in Locators (Preferred)

```typescript
// By test ID (most stable)
page.getByTestId('submit-order')

// By role (accessible)
page.getByRole('button', { name: 'Place Order' })
page.getByRole('heading', { level: 1 })
page.getByRole('textbox', { name: 'Email' })

// By label (form elements)
page.getByLabel('Email address')

// By placeholder
page.getByPlaceholder('Enter your email')

// By text
page.getByText('Welcome back')
page.getByText(/total: \$\d+/)

// By alt text (images)
page.getByAltText('Company logo')

// By title attribute
page.getByTitle('Close dialog')
```

### Scoping and Filtering

```typescript
// Scope to a container
const card = page.getByTestId('product-card').first()
await card.getByRole('button', { name: 'Add to cart' }).click()

// Filter locators
page.getByRole('listitem').filter({ hasText: 'Premium' })
page.getByRole('row').filter({ has: page.getByText('Active') })

// Chain locators
page.getByTestId('nav').getByRole('link', { name: 'Settings' })
```

### Locator Best Practices
- Use `page.locator()` only when built-in methods don't apply
- Avoid `page.$()` and `page.$$()` — use `page.locator()` instead
- Use `locator.filter()` for dynamic scoped selections
- Use `locator.nth()` only when element order is semantically meaningful
