const { test, expect } = require('@playwright/test')
const { ADMIN, MEMBER, login, unique } = require('./helpers')

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
    await page.goto('/admin/agencies')
    const agenciesBefore = await page.locator('table tbody tr').count()
    await page.goto('/admin/agencies/new')
    await page.locator('#agency_name').waitFor()
    const name = unique('Admin Agency')
    await page.locator('#agency_name').fill(name)
    const stateField = page.locator('.field-unit--belongs-to').filter({ has: page.locator('label', { hasText: 'State' }) })
    await stateField.locator('.selectize-input').click()
    await page.locator('.selectize-dropdown').last().locator('.option').first().click()
    const createResponse = page.waitForResponse(
      (response) => response.request().method() === 'POST' && /\/admin\/agencies\/?$/.test(new URL(response.url()).pathname)
    )
    await page.getByRole('button', { name: /Create Agency/i }).click()
    expect((await createResponse).status()).toBe(302)
    await page.goto('/admin/agencies')
    await expect(page.locator('table tbody tr')).toHaveCount(agenciesBefore + 1)
  })

  test('error: non-admin cannot open the form', async ({ page }) => {
    await login(page, MEMBER)
    await page.goto('/admin/agencies/new')
    await expect(page.getByText('You are not an admin')).toBeVisible()
  })

  test('error: blank name is rejected', async ({ page }) => {
    await login(page, ADMIN)
    await page.goto('/admin/agencies/new')
    await page.locator('#agency_name').waitFor()
    const form = page.locator('form').filter({ has: page.getByRole('button', { name: /Create Agency/i }) })
    await form.evaluate((el) => {
      el.noValidate = true
    })
    await page.getByRole('button', { name: /Create Agency/i }).click()
    await expect(page.locator('#error_explanation')).toContainText(/Please enter a name|prohibited/i)
  })
})
