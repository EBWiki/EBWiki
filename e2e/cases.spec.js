const { test, expect } = require('@playwright/test')
const {
  login,
  expectAuthRequired,
  expectNotFound,
  expectFlash,
  disableHtml5,
  fillNewCase
} = require('./helpers')

test.describe('browse cases', () => {
  test('happy path: home page lists tracked cases', async ({ page }) => {
    await page.goto('/')
    await expect(page.getByRole('heading', { name: /cases of people killed by police/i })).toBeVisible()
    await expect(page.getByRole('heading', { name: 'Recently Updated' })).toBeVisible()
    await expect(page.getByRole('link', { name: /Sven Svensson/ })).toBeVisible()
  })

  test('error: unknown case slug is not found', async ({ page }) => {
    await page.goto('/cases/this-case-does-not-exist')
    await expectNotFound(page)
  })

  test('error: empty high pagination page has no cases', async ({ page }) => {
    await page.goto('/?page=999')
    await expect(page.getByText(/No (entries|cases) found|Displaying .* 0/i)).toBeVisible()
  })
})

test.describe('view case', () => {
  test('happy path: case show renders', async ({ page }) => {
    await page.goto('/cases/sven-svensson')
    await expect(page).toHaveTitle(/Sven Svensson/)
    await expect(page.getByText(/Cause of death/)).toBeVisible()
    await expect(page.getByRole('button', { name: 'Follow' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'History' })).toBeVisible()
  })

  test('error: unknown slug is not found', async ({ page }) => {
    await page.goto('/cases/missing-person-case')
    await expectNotFound(page)
  })

  test('error: numeric id that does not exist is not found', async ({ page }) => {
    await page.goto('/cases/999999')
    await expectNotFound(page)
  })
})

test.describe('create case', () => {
  test('happy path: signed-in user creates a case', async ({ page }) => {
    await login(page)
    await page.goto('/cases/new')
    const title = await fillNewCase(page)
    await page.getByRole('button', { name: 'Create Case' }).click()
    await expectFlash(page, 'Case was created!')
    await expect(page).toHaveTitle(new RegExp(title))
  })

  test('error: guest is sent to sign in', async ({ page }) => {
    await page.goto('/cases/new')
    await expectAuthRequired(page)
  })

  test('error: future date is rejected', async ({ page }) => {
    await login(page)
    await page.goto('/cases/new')
    await fillNewCase(page, { date: '2099-01-01' })
    await page.getByRole('button', { name: 'Create Case' }).click()
    await expect(page.getByRole('heading', { name: 'New Case' })).toBeVisible()
    await expect(page.locator('#error_explanation')).toContainText(/must be in the past/i)
  })
})

test.describe('edit case', () => {
  test('happy path: signed-in user updates a case', async ({ page }) => {
    await login(page)
    await page.goto('/cases/sven-svensson/edit')
    await expect(page.getByRole('heading', { name: /Editing Case Sven Svensson/ })).toBeVisible()
    await page.getByLabel('Summary').fill(`E2E edit ${Date.now()}`)
    await page.getByRole('button', { name: 'Update Case' }).click()
    await expectFlash(page, 'Case was updated!')
    await expect(page).toHaveTitle(/Sven Svensson/)
  })

  test('error: guest is sent to sign in', async ({ page }) => {
    await page.goto('/cases/sven-svensson/edit')
    await expectAuthRequired(page)
  })

  test('error: blank title is rejected', async ({ page }) => {
    await login(page)
    await page.goto('/cases/sven-svensson/edit')
    const form = page.locator('form').filter({ has: page.getByRole('button', { name: 'Update Case' }) })
    await disableHtml5(form)
    await page.getByLabel('Title').fill('')
    await page.getByLabel('Summary').fill('Tried to clear the title')
    await page.getByRole('button', { name: 'Update Case' }).click()
    await expect(page.locator('#error_explanation')).toContainText('Please specify a title')
  })
})

test.describe('case history', () => {
  test('happy path: history lists versions', async ({ page }) => {
    await page.goto('/cases/sven-svensson/history')
    await expect(page.getByRole('heading', { name: 'History' })).toBeVisible()
    await expect(page.getByText('Description of changes:')).toBeVisible()
  })

  test('error: unknown slug has no history', async ({ page }) => {
    await page.goto('/cases/not-a-real-case/history')
    await expect(page.getByRole('heading', { name: 'There is no history for this case.' })).toBeVisible()
  })

  test('error: legacy article history still resolves or reports missing', async ({ page }) => {
    await page.goto('/articles/not-a-real-case/history')
    await expect(page.getByRole('heading', { name: /History|There is no history for this case/ })).toBeVisible()
  })
})

test.describe('case followers', () => {
  test('happy path: empty followers state', async ({ page }) => {
    await page.goto('/cases/janez-novak/followers')
    await expect(
      page.getByRole('heading', { name: /no one currently following this case|follower/i })
    ).toBeVisible()
  })

  test('error: unknown slug is not found', async ({ page }) => {
    await page.goto('/cases/missing-case/followers')
    await expectNotFound(page)
  })

  test('error: follow from the followers page still requires a real case', async ({ page }) => {
    await page.goto('/cases/999999/followers')
    await expectNotFound(page)
  })
})

test.describe('follow case', () => {
  test('happy path: signed-in user follows and unfollows', async ({ page }) => {
    await login(page)
    await page.goto('/cases/kari-holm')
    if (await page.getByRole('button', { name: 'Unfollow' }).isVisible()) {
      page.once('dialog', (dialog) => dialog.accept())
      await page.getByRole('button', { name: 'Unfollow' }).click()
    }
    await page.getByRole('button', { name: 'Follow' }).click()
    await expect(page.getByRole('button', { name: 'Unfollow' })).toBeVisible()
    page.once('dialog', (dialog) => dialog.accept())
    await page.getByRole('button', { name: 'Unfollow' }).click()
    await expect(page.getByRole('button', { name: 'Follow' })).toBeVisible()
  })

  test('error: guest follow is sent to sign in', async ({ page }) => {
    await page.goto('/cases/sven-svensson')
    await page.getByRole('button', { name: 'Follow' }).click()
    await expect(page).toHaveURL(/\/users\/sign_in/)
  })

  test('error: follow on an unknown case is not found', async ({ page }) => {
    await login(page)
    await page.goto('/cases/999999')
    await expectNotFound(page)
  })
})
