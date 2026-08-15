const { test, expect } = require('@playwright/test')

test.describe('public pages', () => {
  test('home page lists tracked cases', async ({ page }) => {
    await page.goto('/')
    await expect(page.getByRole('heading', { name: /cases of people killed by police/i })).toBeVisible()
    await expect(page.getByRole('heading', { name: 'Recently Updated' })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Login' }).first()).toBeVisible()
  })

  test('search finds a seeded case', async ({ page }) => {
    await page.goto('/')
    await page.getByPlaceholder('Name, City or Keywords...').fill('Sven')
    await page.getByRole('button', { name: 'Search' }).click()
    await expect(page.getByRole('heading', { name: /Your search for "Sven"/ })).toBeVisible()
    await expect(page.getByRole('link', { name: /Sven Svensson/ })).toBeVisible()
  })

  test('case show page renders', async ({ page }) => {
    await page.goto('/cases/sven-svensson')
    await expect(page).toHaveTitle(/Sven Svensson/)
    await expect(page.getByText(/Cause of death/)).toBeVisible()
    await expect(page.getByRole('button', { name: 'Follow' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'History' })).toBeVisible()
  })

  test('instructions accordion expands', async ({ page }) => {
    await page.goto('/instructions')
    await expect(page.getByRole('heading', { name: 'Instructions:' })).toBeVisible()
    await page.getByRole('button', { name: 'Editing a case' }).click()
    await expect(page.getByText(/Click on the Edit button beneath the image/)).toBeVisible()
  })
})
