const { test, expect } = require('@playwright/test')
const { login } = require('./helpers')

test.describe('maps', () => {
  test('happy path: map index explains the pins', async ({ page }) => {
    await page.goto('/maps')
    await expect(page.getByRole('heading', { name: /Click on the map pins below to learn more/ })).toBeVisible()
    await expect(page.locator('#map-container')).toBeVisible()
    await expect(page.getByRole('link', { name: 'Back to the Main Page' })).toBeVisible()
  })

  test('error: guest is prompted to log in instead of seeing follow instructions', async ({ page }) => {
    await page.goto('/maps')
    await expect(page.getByRole('link', { name: 'Login' }).first()).toBeVisible()
    await expect(page.getByText(/follow specific cases/i)).toBeVisible()
  })

  test('error: signed-in user no longer sees the guest login prompt on the map', async ({ page }) => {
    await login(page)
    await page.goto('/maps')
    await expect(page.getByText(/Click the follow button below the image/)).toBeVisible()
    await expect(page.getByText(/follow specific cases and we will update you/)).toHaveCount(0)
  })
})
