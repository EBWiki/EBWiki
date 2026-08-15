const { test, expect } = require('@playwright/test')
const { login, MEMBER, expectNotFound, expectFlash, unique } = require('./helpers')

test.describe('organizations', () => {
  test('happy path: create and view an organization', async ({ page }) => {
    const name = unique('E2E Org')
    await page.goto('/organizations/new')
    await page.getByLabel('Name').fill(name)
    await page.getByLabel('Description').fill('A community organization used in e2e.')
    await page.getByRole('button', { name: 'Create Organization' }).click()
    await expectFlash(page, 'Organization was successfully created.')
    await expect(page.getByText(name)).toBeVisible()
    await expect(page.getByText('A community organization used in e2e.')).toBeVisible()
  })

  test('error: non-admin cannot edit', async ({ page }) => {
    await page.goto('/organizations/new')
    const name = unique('Locked Org')
    await page.getByLabel('Name').fill(name)
    await page.getByRole('button', { name: 'Create Organization' }).click()
    const showUrl = page.url()
    const editUrl = `${showUrl.replace(/\/$/, '')}/edit`

    await login(page, MEMBER)
    await page.goto(editUrl)
    await expect(page.getByText('You are not authorized to perform this action.')).toBeVisible()
  })

  test('error: unknown organization is not found', async ({ page }) => {
    await page.goto('/organizations/999999')
    await expectNotFound(page)
  })
})
