const { test, expect } = require('@playwright/test')
const { ADMIN, MEMBER, login, expectFlash, unique } = require('./helpers')

test.describe('admin dashboard', () => {
  test('happy path: admin can open the agencies dashboard', async ({ page }) => {
    await login(page, ADMIN)
    await page.goto('/admin')
    await expect(page.getByText('Agencies').first()).toBeVisible()
  })

  test('error: guest is not an admin', async ({ page }) => {
    await page.goto('/admin')
    await expect(page.getByText('You are not an admin')).toBeVisible()
    await expect(page).toHaveURL(/\/$|\/\?/)
  })

  test('error: signed-in non-admin is blocked', async ({ page }) => {
    await login(page, MEMBER)
    await page.goto('/admin')
    await expect(page.getByText('You are not an admin')).toBeVisible()
  })
})

test.describe('admin agency create', () => {
  test('happy path: admin creates an agency', async ({ page }) => {
    await login(page, ADMIN)
    await page.goto('/admin/agencies/new')
    const name = unique('Admin Agency')
    await page.getByLabel('Name').fill(name)
    const state = page.getByLabel('State')
    if (await state.count()) {
      const options = await state.locator('option').allTextContents()
      const texas = options.find((label) => label.includes('Texas'))
      if (texas) await state.selectOption({ label: texas.trim() })
    }
    await page.getByRole('button', { name: /Create Agency/i }).click()
    await expect(page.getByText(/Agency was successfully created|successfully created/i)).toBeVisible()
    await expect(page.getByText(name)).toBeVisible()
  })

  test('error: non-admin cannot open the form', async ({ page }) => {
    await login(page, MEMBER)
    await page.goto('/admin/agencies/new')
    await expect(page.getByText('You are not an admin')).toBeVisible()
  })

  test('error: blank name is rejected', async ({ page }) => {
    await login(page, ADMIN)
    await page.goto('/admin/agencies/new')
    const form = page.locator('form').filter({ has: page.getByRole('button', { name: /Create Agency/i }) })
    await form.evaluate((el) => {
      el.noValidate = true
    })
    await page.getByRole('button', { name: /Create Agency/i }).click()
    await expect(page.getByText(/Please enter a name|can't be blank|prohibited/i)).toBeVisible()
  })
})
