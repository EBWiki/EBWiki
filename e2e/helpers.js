const E2E_EMAIL = process.env.E2E_EMAIL || 'jdoe@example.com'
const E2E_PASSWORD = process.env.E2E_PASSWORD || 'password'

async function login(page, email = E2E_EMAIL, password = E2E_PASSWORD) {
  await page.goto('/users/sign_in')
  await page.getByLabel('Email').fill(email)
  await page.getByLabel('Password').fill(password)
  await page.getByRole('button', { name: 'Log in' }).click()
  await page.waitForURL((url) => !url.pathname.includes('/users/sign_in'))
}

module.exports = { E2E_EMAIL, E2E_PASSWORD, login }
