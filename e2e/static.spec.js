const { test, expect } = require('@playwright/test')
const { expectNotFound } = require('./helpers')

test.describe('static pages', () => {
  test('happy path: about, guidelines, instructions, get involved, how to help', async ({ page }) => {
    await page.goto('/about')
    await expect(page.getByRole('heading', { name: 'About EBWiki:' })).toBeVisible()
    await expect(page.getByRole('heading', { name: 'Our Mission:' })).toBeVisible()

    await page.goto('/guidelines')
    await expect(page.getByRole('heading', { name: 'EBWiki Guidelines for Adding Content:' })).toBeVisible()

    await page.goto('/instructions')
    await expect(page.getByRole('heading', { name: 'Instructions:' })).toBeVisible()
    await page.getByRole('button', { name: 'Editing a case' }).click()
    await expect(page.getByText(/Click on the Edit button beneath the image/)).toBeVisible()

    await page.goto('/get-involved')
    await expect(page.getByRole('heading', { name: 'How to Make Your Voice Heard' })).toBeVisible()

    await page.goto('/how-to-help')
    await expect(page.getByRole('heading', { name: 'How You Can Help EBWiki' })).toBeVisible()
  })

  test('error: unknown path is not found', async ({ page }) => {
    await page.goto('/this-page-is-not-a-real-route')
    await expectNotFound(page)
  })

  test('error: guidelines is not the accordion instructions page', async ({ page }) => {
    await page.goto('/guidelines')
    await expect(page.getByRole('button', { name: 'Editing a case' })).toHaveCount(0)
    await expect(page.getByRole('heading', { name: 'Instructions:' })).toHaveCount(0)
  })
})
