const { test, expect } = require('@playwright/test')
const { login, E2E_EMAIL } = require('./helpers')

test.describe('authenticated flows', () => {
  test('login reaches the home page', async ({ page }) => {
    await login(page)
    await expect(page.getByText(E2E_EMAIL)).toBeVisible()
    await expect(page.getByRole('link', { name: 'Add a New Case' })).toBeVisible()
  })

  test('mailbox inbox and compose form', async ({ page }) => {
    await login(page)
    await page.goto('/mailbox/inbox')
    await expect(page.getByRole('link', { name: 'Inbox' })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Sent' })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Trash' })).toBeVisible()
    await page.getByRole('link', { name: 'Compose a message' }).click()
    await expect(page.getByLabel('Subject')).toBeVisible()
    await expect(page.getByRole('button', { name: 'Send Message' })).toBeVisible()
  })

  test('new case form loads Trix editors', async ({ page }) => {
    await login(page)
    await page.goto('/cases/new')
    await expect(page.getByRole('heading', { name: 'New Case' })).toBeVisible()
    await expect(page.locator('trix-editor')).toHaveCount(3)
    await expect(page.getByRole('button', { name: 'Create Case' })).toBeVisible()
  })
})
