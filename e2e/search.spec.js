const { test, expect } = require('@playwright/test')

test.describe('search cases', () => {
  test('happy path: keyword finds a seeded case', async ({ page }) => {
    await page.goto('/')
    await page.getByPlaceholder('Name, City or Keywords...').fill('Sven')
    await page.getByRole('button', { name: 'Search' }).click()
    await expect(page.getByRole('heading', { name: /Your search for "Sven"/ })).toBeVisible()
    await expect(page.getByRole('link', { name: /Sven Svensson/ })).toBeVisible()
  })

  test('error: no matches', async ({ page }) => {
    await page.goto('/')
    await page.getByPlaceholder('Name, City or Keywords...').fill('zzzznonexistentquery')
    await page.getByRole('button', { name: 'Search' }).click()
    await expect(page.getByRole('heading', { name: /has returned 0 results/ })).toBeVisible()
  })

  test('error: empty query returns the unfiltered listing copy', async ({ page }) => {
    await page.goto('/')
    await page.getByRole('button', { name: 'Search' }).click()
    await expect(page.getByRole('heading', { name: /Your search for cases has returned/ })).toBeVisible()
  })
})
