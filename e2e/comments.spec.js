const { test, expect } = require('@playwright/test')
const { login, expectAuthRequired, disableHtml5, expectFlash } = require('./helpers')

test.describe('comment on a case', () => {
  test('happy path: signed-in user posts a comment', async ({ page }) => {
    await login(page)
    await page.goto('/cases/sven-svensson')
    await page.getByPlaceholder('Comment on this case').fill(`E2E comment ${Date.now()}`)
    await page.getByRole('button', { name: 'Create Comment' }).click()
    await expectFlash(page, 'Comment created!')
    await expect(page.getByText(/E2E comment/)).toBeVisible()
  })

  test('error: guest submit is sent to sign in', async ({ page }) => {
    await page.goto('/cases/sven-svensson')
    await page.getByPlaceholder('Comment on this case').fill('Guest should not post this')
    await page.getByRole('button', { name: 'Create Comment' }).click()
    await expectAuthRequired(page)
  })

  test('error: blank comment is blocked', async ({ page }) => {
    await login(page)
    await page.goto('/cases/sven-svensson')
    const form = page.locator('form').filter({
      has: page.getByPlaceholder('Comment on this case')
    })
    await disableHtml5(form)
    await page.getByRole('button', { name: 'Create Comment' }).click()
    await expect(page).toHaveURL(/\/cases\/sven-svensson/)
    await expect(page.getByText(/Please correct the following errors|Content can't be blank|Comment created!/)).toBeVisible()
  })
})
