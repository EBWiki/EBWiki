const { test, expect } = require('@playwright/test')
const {
  ADMIN,
  MEMBER,
  login,
  expectNotFound,
  expectFlash,
  disableHtml5
} = require('./helpers')

test.describe('user profile', () => {
  test('happy path: signed-in user views their profile', async ({ page }) => {
    await login(page, ADMIN)
    await page.locator('a.dropdown-toggle', { hasText: ADMIN.email }).click()
    await page.getByRole('link', { name: 'Profile' }).click()
    await expect(page.getByText(/John Doe/)).toBeVisible()
    await expect(page.getByText(/bio:/)).toBeVisible()
    await expect(page.getByRole('link', { name: 'Edit profile' })).toBeVisible()
  })

  test('error: unknown user is not found', async ({ page }) => {
    await page.goto('/users/999999')
    await expectNotFound(page)
  })

  test('error: non-admin cannot edit another profile', async ({ page }) => {
    await login(page, MEMBER)
    await page.goto('/users/john-doe/edit')
    await expect(page.getByText('You are not authorized to perform this action.')).toBeVisible()
  })
})

test.describe('edit profile', () => {
  test('happy path: user updates their bio', async ({ page }) => {
    await login(page, MEMBER)
    await page.locator('a.dropdown-toggle', { hasText: MEMBER.email }).click()
    await page.getByRole('link', { name: 'Profile' }).click()
    await page.getByRole('link', { name: 'Edit profile' }).click()
    const bio = `E2E bio ${Date.now()}`
    await page.getByLabel('Bio').fill(bio)
    await page.getByRole('button', { name: 'Update profile' }).click()
    await expectFlash(page, 'Your profile was updated!')
    await expect(page.getByText(bio)).toBeVisible()
  })

  test('error: blank name is rejected', async ({ page }) => {
    await login(page, MEMBER)
    await page.locator('a.dropdown-toggle', { hasText: MEMBER.email }).click()
    await page.getByRole('link', { name: 'Profile' }).click()
    await page.getByRole('link', { name: 'Edit profile' }).click()
    const form = page.locator('form').filter({ has: page.getByRole('button', { name: 'Update profile' }) })
    await disableHtml5(form)
    await page.getByLabel('Name').fill('')
    await page.getByRole('button', { name: 'Update profile' }).click()
    await expect(page.locator('#error_explanation')).toContainText('Please add a name.')
  })

  test('error: guest cannot open the edit form', async ({ page }) => {
    await page.goto('/users/jane-smith/edit')
    await expect(page.getByText(/You are not authorized|You need to sign in/)).toBeVisible()
  })
})
