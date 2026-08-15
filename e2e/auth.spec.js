const { test, expect } = require('@playwright/test')
const {
  ADMIN,
  MEMBER,
  login,
  logout,
  expectAuthRequired,
  expectFlash
} = require('./helpers')

test.describe('sign in', () => {
  test('happy path: valid credentials reach the home page', async ({ page }) => {
    await login(page, ADMIN)
    await expectFlash(page, 'Signed in successfully.')
    await expect(page.getByText(ADMIN.email)).toBeVisible()
    await expect(page.getByRole('link', { name: 'Add a New Case' })).toBeVisible()
  })

  test('error: unknown email', async ({ page }) => {
    await page.goto('/users/sign_in')
    await page.getByLabel('Email').fill('nobody@example.com')
    await page.getByLabel('Password').fill('password')
    await page.getByRole('button', { name: 'Log in' }).click()
    await expect(page.getByText('Invalid email or password.')).toBeVisible()
  })

  test('error: wrong password', async ({ page }) => {
    await page.goto('/users/sign_in')
    await page.getByLabel('Email').fill(ADMIN.email)
    await page.getByLabel('Password').fill('not-the-password')
    await page.getByRole('button', { name: 'Log in' }).click()
    await expect(page.getByText('Invalid email or password.')).toBeVisible()
  })
})

test.describe('sign up', () => {
  test('happy path: new account is created but unconfirmed', async ({ page }) => {
    const email = `e2e-${Date.now()}@example.com`
    await page.goto('/users/sign_up')
    await page.getByLabel('Name').fill('E2E Signup')
    await page.getByLabel('Email').fill(email)
    await page.getByLabel('Password', { exact: true }).fill('password12')
    await page.getByLabel('Password confirmation').fill('password12')
    await page.getByRole('button', { name: 'Sign up' }).click()
    await expect(
      page.getByText(/confirmation link has been sent to your email address/i)
    ).toBeVisible()
  })

  test('error: password confirmation does not match', async ({ page }) => {
    await page.goto('/users/sign_up')
    await page.getByLabel('Name').fill('E2E Mismatch')
    await page.getByLabel('Email').fill(`mismatch-${Date.now()}@example.com`)
    await page.getByLabel('Password', { exact: true }).fill('password12')
    await page.getByLabel('Password confirmation').fill('password99')
    await page.getByRole('button', { name: 'Sign up' }).click()
    await expect(page.getByText(/Password confirmation doesn't match Password/i)).toBeVisible()
  })

  test('error: email already taken', async ({ page }) => {
    await page.goto('/users/sign_up')
    await page.getByLabel('Name').fill('E2E Duplicate')
    await page.getByLabel('Email').fill(ADMIN.email)
    await page.getByLabel('Password', { exact: true }).fill('password12')
    await page.getByLabel('Password confirmation').fill('password12')
    await page.getByRole('button', { name: 'Sign up' }).click()
    await expect(page.getByText(/Email has already been taken/i)).toBeVisible()
  })
})

test.describe('sign out', () => {
  test('happy path: session ends and login returns', async ({ page }) => {
    await login(page, ADMIN)
    await logout(page, ADMIN)
  })

  test('error: guest has no log out control', async ({ page }) => {
    await page.goto('/')
    await expect(page.getByRole('button', { name: 'Log Out' })).toHaveCount(0)
    await expect(page.getByRole('link', { name: 'Login' }).first()).toBeVisible()
  })

  test('error: mailbox requires auth after logout', async ({ page }) => {
    await login(page, MEMBER)
    await logout(page, MEMBER)
    await page.goto('/mailbox/inbox')
    await expectAuthRequired(page)
  })
})

test.describe('password reset', () => {
  test('happy path: reset instructions are accepted', async ({ page }) => {
    await page.goto('/users/password/new')
    await page.getByLabel('Email').fill(ADMIN.email)
    await page.getByRole('button', { name: 'Send me reset password instructions' }).click()
    await expect(
      page.getByText(/email with instructions for how to reset your password/i)
    ).toBeVisible()
  })

  test('error: blank email', async ({ page }) => {
    await page.goto('/users/password/new')
    const form = page.locator('form').filter({
      has: page.getByRole('button', { name: 'Send me reset password instructions' })
    })
    await form.evaluate((el) => {
      el.noValidate = true
    })
    await page.getByRole('button', { name: 'Send me reset password instructions' }).click()
    await expect(page.getByText(/Email can't be blank/i)).toBeVisible()
  })

  test('error: invalid email format', async ({ page }) => {
    await page.goto('/users/password/new')
    const form = page.locator('form').filter({
      has: page.getByRole('button', { name: 'Send me reset password instructions' })
    })
    await form.evaluate((el) => {
      el.noValidate = true
    })
    await page.getByLabel('Email').fill('not-an-email')
    await page.getByRole('button', { name: 'Send me reset password instructions' }).click()
    await expect(page.getByText(/Email is invalid/i)).toBeVisible()
  })
})
