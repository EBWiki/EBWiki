const { expect } = require('@playwright/test')

const ADMIN = {
  email: process.env.E2E_EMAIL || 'jdoe@example.com',
  password: process.env.E2E_PASSWORD || 'password',
  name: 'John Doe'
}
const MEMBER = {
  email: process.env.E2E_MEMBER_EMAIL || 'jsmith@example.com',
  password: process.env.E2E_MEMBER_PASSWORD || 'password',
  name: 'Jane Smith'
}

const SIGN_IN_NOTICE = 'You need to sign in or sign up before continuing.'
const NOT_FOUND = /Couldn't find|RecordNotFound|doesn't exist/i

async function login(page, user = ADMIN) {
  await page.goto('/users/sign_in')
  await page.getByLabel('Email').fill(user.email)
  await page.getByLabel('Password').fill(user.password)
  await page.getByRole('button', { name: 'Log in' }).click()
  await page.waitForURL((url) => !url.pathname.includes('/users/sign_in'))
}

async function logout(page, user = ADMIN) {
  await page.locator('a.dropdown-toggle', { hasText: user.email }).click()
  await page.getByRole('button', { name: 'Log Out' }).click()
  await expectSignedOut(page)
}

async function expectSignedOut(page) {
  await expectFlash(page, 'Signed out successfully.')
  await expect(page.getByRole('link', { name: 'Login' }).first()).toBeVisible()
}

async function expectAuthRequired(page) {
  await expect(page).toHaveURL(/\/users\/sign_in/)
  await expect(page.getByText(SIGN_IN_NOTICE)).toBeVisible()
}

async function expectNotFound(page) {
  await expect(page.getByText(NOT_FOUND)).toBeVisible()
}

async function expectFlash(page, text) {
  await expect(page.getByText(text)).toBeVisible()
}

async function disableHtml5(form) {
  await form.evaluate((el) => {
    el.noValidate = true
  })
}

async function fillTrix(page, inputId, text) {
  const editor = page.locator(`trix-editor[input="${inputId}"]`)
  await editor.waitFor()
  await page.evaluate(
    ({ id, value }) => {
      document.querySelector(`trix-editor[input="${id}"]`).editor.loadHTML(value)
    },
    { id: inputId, value: text }
  )
}

async function fillNewCase(page, overrides = {}) {
  const title = overrides.title || `E2E Case ${Date.now()}`
  await page.getByLabel('Title').fill(title)
  await page.locator('#case_date').fill(overrides.date || '2018-06-15')
  await page.locator('#case_cause_of_death').selectOption(overrides.cause || 'shooting')
  await page.getByRole('link', { name: 'Add a Subject' }).click()
  await page.locator('.nested-fields input[name*="[name]"]').first().fill(overrides.subject || 'E2E Victim')
  await page.getByLabel('City').fill(overrides.city || 'Houston')
  await page.locator('#case_state_id').selectOption({ label: overrides.state || 'Texas' })
  await fillTrix(page, 'case_overview', overrides.overview || 'Overview of the incident for e2e.')
  await page.getByLabel('Blurb').fill(overrides.blurb || 'A short blurb about the case.')
  await page.getByLabel('Summary').fill(overrides.summary || 'Created via Playwright e2e.')
  return title
}

function unique(prefix) {
  return `${prefix} ${Date.now()}`
}

module.exports = {
  ADMIN,
  MEMBER,
  SIGN_IN_NOTICE,
  login,
  logout,
  expectAuthRequired,
  expectNotFound,
  expectFlash,
  expectSignedOut,
  disableHtml5,
  fillTrix,
  fillNewCase,
  unique
}
