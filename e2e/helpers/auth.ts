import { expect, type APIRequestContext, type Page } from '@playwright/test';

export const E2E_EMAIL = 'e2e@example.com';
export const E2E_PASSWORD = 'e2e-password';

export async function resetFriendlyPhotoFixtures(request: APIRequestContext) {
  const response = await request.post('/e2e/friendly_photos/reset');
  expect(response.ok(), `fixture reset failed: ${response.status()}`).toBeTruthy();
}

export async function stubConfirms(page: Page) {
  await page.addInitScript(() => {
    window.confirm = () => true;
  });
}

export async function loginAsEditor(page: Page) {
  await stubConfirms(page);
  await page.goto('/users/sign_in');
  await page.locator('#user_email').fill(E2E_EMAIL);
  await page.locator('#user_password').fill(E2E_PASSWORD);
  await page.getByRole('button', { name: 'Log in' }).click();
  await expect(page.locator('body')).toContainText(E2E_EMAIL);
}

export async function acceptConfirms(page: Page) {
  await stubConfirms(page);
  page.on('dialog', (dialog) => dialog.accept());
}
