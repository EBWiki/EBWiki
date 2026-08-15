const { test, expect } = require('@playwright/test')
const {
  ADMIN,
  MEMBER,
  login,
  expectAuthRequired,
  expectNotFound,
  expectFlash,
  unique
} = require('./helpers')

test.describe('mailbox folders', () => {
  test('happy path: inbox, sent, and trash are reachable', async ({ page }) => {
    await login(page, ADMIN)
    await page.goto('/mailbox/inbox')
    await expect(page.getByRole('link', { name: 'Inbox' })).toBeVisible()
    await page.getByRole('link', { name: 'Sent' }).click()
    await expect(page).toHaveURL(/\/mailbox\/sent/)
    await page.getByRole('link', { name: 'Trash' }).click()
    await expect(page).toHaveURL(/\/mailbox\/trash/)
    await expect(page.getByRole('link', { name: 'Compose a message' })).toBeVisible()
  })

  test('error: guest cannot open inbox', async ({ page }) => {
    await page.goto('/mailbox/inbox')
    await expectAuthRequired(page)
  })

  test('error: guest cannot open sent mail', async ({ page }) => {
    await page.goto('/mailbox/sent')
    await expectAuthRequired(page)
  })
})

test.describe('compose message', () => {
  test('happy path: send a message to another user', async ({ page }) => {
    await login(page, ADMIN)
    await page.goto('/conversations/new')
    await page.locator('select[name="conversation[recipients][]"]').selectOption({ label: MEMBER.name })
    const subject = unique('E2E subject')
    await page.getByLabel('Subject').fill(subject)
    await page.getByPlaceholder('Type your message here').fill('Hello from Playwright.')
    await page.getByRole('button', { name: 'Send Message' }).click()
    await expectFlash(page, 'Your message was successfully sent!')
    await expect(page.getByText(subject)).toBeVisible()
    await expect(page.getByText('Hello from Playwright.')).toBeVisible()
  })

  test('error: guest is sent to sign in', async ({ page }) => {
    await page.goto('/conversations/new')
    await expectAuthRequired(page)
  })

  test('error: blank subject and body are rejected', async ({ page }) => {
    await login(page, ADMIN)
    await page.goto('/conversations/new')
    await page.getByRole('button', { name: 'Send Message' }).click()
    await expect(page.getByText('Subject and message are required.')).toBeVisible()
  })
})

test.describe('reply and trash', () => {
  test('happy path: reply, trash, and restore a conversation', async ({ page }) => {
    await login(page, ADMIN)
    await page.goto('/conversations/new')
    await page.locator('select[name="conversation[recipients][]"]').selectOption({ label: MEMBER.name })
    const subject = unique('E2E thread')
    await page.getByLabel('Subject').fill(subject)
    await page.getByPlaceholder('Type your message here').fill('First message')
    await page.getByRole('button', { name: 'Send Message' }).click()
    await page.getByPlaceholder('Reply Message').fill('Thanks for reading.')
    await page.getByRole('button', { name: 'Reply' }).click()
    await expectFlash(page, 'Your reply message was successfully sent!')
    await expect(page.getByText('Thanks for reading.')).toBeVisible()

    page.once('dialog', (dialog) => dialog.accept())
    await page.getByRole('button', { name: 'Move to trash' }).click()
    await expect(page).toHaveURL(/\/mailbox\/inbox/)
    await page.getByRole('link', { name: 'Trash' }).click()
    await page.getByRole('link', { name: subject }).click()
    await page.getByRole('button', { name: 'Untrash' }).click()
    await expect(page).toHaveURL(/\/mailbox\/inbox/)
  })

  test('error: blank reply is rejected', async ({ page }) => {
    await login(page, ADMIN)
    await page.goto('/conversations/new')
    await page.locator('select[name="conversation[recipients][]"]').selectOption({ label: MEMBER.name })
    await page.getByLabel('Subject').fill(unique('E2E blank reply'))
    await page.getByPlaceholder('Type your message here').fill('Needs a reply')
    await page.getByRole('button', { name: 'Send Message' }).click()
    await page.getByRole('button', { name: 'Reply' }).click()
    await expect(page.getByText('Reply cannot be blank.')).toBeVisible()
  })

  test('error: unknown conversation is not found', async ({ page }) => {
    await login(page, ADMIN)
    await page.goto('/conversations/999999')
    await expectNotFound(page)
  })
})
