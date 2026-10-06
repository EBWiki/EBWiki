const { test, expect } = require('@playwright/test')
const {
  login,
  expectAuthRequired,
  expectNotFound,
  expectFlash,
  disableHtml5,
  unique
} = require('./helpers')

test.describe('list and view agencies', () => {
  test('happy path: index and show a seeded agency', async ({ page }) => {
    await page.goto('/agencies')
    await expect(page.getByRole('heading', { name: 'Agencies' })).toBeVisible()
    await page.getByRole('link', { name: /City of Houston Police Department/ }).click()
    await expect(page.getByRole('heading', { name: /City of Houston Police Department/ })).toBeVisible()
    await expect(page.getByText(/Jurisdiction:/)).toBeVisible()
  })

  test('error: unknown agency slug is not found', async ({ page }) => {
    await page.goto('/agencies/not-a-real-agency')
    await expectNotFound(page)
  })

  test('error: guest cannot open the new agency form', async ({ page }) => {
    await page.goto('/agencies/new')
    await expectAuthRequired(page)
  })
})

test.describe('create agency', () => {
  test('happy path: signed-in user creates an agency', async ({ page }) => {
    await login(page)
    await page.goto('/agencies')
    await page.getByRole('link', { name: 'Add a New Agency' }).click()
    const name = unique('E2E Agency')
    await page.getByLabel('Name').fill(name)
    await page.locator('#agency_state_id').selectOption({ label: 'Texas' })
    await page.getByRole('button', { name: 'Create Agency' }).click()
    await expectFlash(page, 'Agency was successfully created.')
    await expect(page.getByText(name)).toBeVisible()
  })

  test('error: guest is sent to sign in', async ({ page }) => {
    await page.goto('/agencies/new')
    await expectAuthRequired(page)
  })

  test('error: duplicate name is rejected', async ({ page }) => {
    await login(page)
    await page.goto('/agencies')
    await page.getByRole('link', { name: 'Add a New Agency' }).click()
    await page.getByLabel('Name').fill('City of Houston Police Department')
    await page.locator('#agency_state_id').selectOption({ label: 'Texas' })
    await page.getByRole('button', { name: 'Create Agency' }).click()
    await expect(page.locator('#error_explanation')).toContainText(/already exists/i)
  })
})

test.describe('edit agency', () => {
  test('happy path: signed-in user updates an agency', async ({ page }) => {
    await login(page)
    await page.goto('/agencies/city-of-beaumont-police-department/edit')
    await expect(page.getByRole('heading', { name: /Editing Agency/ })).toBeVisible()
    await page.getByLabel('City').fill('Beaumont')
    await page.getByRole('button', { name: 'Update Agency' }).click()
    await expectFlash(page, 'Agency was successfully updated.')
  })

  test('error: guest is sent to sign in', async ({ page }) => {
    await page.goto('/agencies/city-of-beaumont-police-department/edit')
    await expectAuthRequired(page)
  })

  test('error: blank name is rejected', async ({ page }) => {
    await login(page)
    await page.goto('/agencies/city-of-beaumont-police-department/edit')
    const form = page.locator('form').filter({ has: page.getByRole('button', { name: 'Update Agency' }) })
    await disableHtml5(form)
    await page.getByLabel('Name').fill('')
    await page.getByRole('button', { name: 'Update Agency' }).click()
    await expect(page.locator('#error_explanation')).toContainText('Please enter a name.')
  })
})
