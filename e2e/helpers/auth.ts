import { expect, type Page } from '@playwright/test';

export const E2E_EMAIL = 'e2e@example.com';
export const E2E_PASSWORD = 'e2e-password';

export async function loginAsEditor(page: Page) {
  await page.goto('/users/sign_in');
  await page.locator('#user_email').fill(E2E_EMAIL);
  await page.locator('#user_password').fill(E2E_PASSWORD);
  await page.getByRole('button', { name: 'Log in' }).click();
  await expect(page.locator('body')).toContainText(E2E_EMAIL);
}

export async function acceptConfirms(page: Page) {
  page.on('dialog', (dialog) => dialog.accept());
}
