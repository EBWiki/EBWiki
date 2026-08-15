import { expect, test } from '@playwright/test';
import { clickTestId, loginAsEditor, resetFriendlyPhotoFixtures } from './helpers/auth';

test.beforeEach(async ({ request }) => {
  await resetFriendlyPhotoFixtures(request);
});

test.describe('Friendly photos', () => {
  test('sends guests to login', async ({ page }) => {
    await page.goto('/friendly_photos');
    await expect(page).toHaveURL(/users\/sign_in/);
    await expect(page.getByRole('heading', { name: 'Log in' })).toBeVisible();
  });

  test('lists people who still need a dignified photo', async ({ page }, testInfo) => {
    await loginAsEditor(page);
    await page.goto('/friendly_photos');

    const navLink = page.getByTestId('friendly-photos-nav');
    if (testInfo.project.name === 'mobile-chrome') {
      await expect(navLink).toBeHidden();
    } else {
      await expect(navLink).toBeVisible();
    }

    await expect(page.getByTestId('friendly-photos-table')).toBeVisible();
    await expect(page.getByTestId('case-row-e2e-missing-photo')).toBeVisible();
    await expect(page.getByTestId('case-row-e2e-mugshot-case')).toBeVisible();
    await expect(page.getByTestId('case-row-e2e-portrait-case')).toHaveCount(0);
  });

  test('filters missing, mugshot, and portrait cases', async ({ page }) => {
    await loginAsEditor(page);
    await page.goto('/friendly_photos');

    await page.getByTestId('filter-missing').click();
    await expect(page).toHaveURL(/filter=missing/);
    await expect(page.getByTestId('case-row-e2e-missing-photo')).toBeVisible();
    await expect(page.getByTestId('case-row-e2e-portrait-case')).toHaveCount(0);

    await page.getByTestId('filter-mugshot').click();
    await expect(page).toHaveURL(/filter=mugshot/);
    await expect(page.getByTestId('case-row-e2e-mugshot-case')).toBeVisible();
    await expect(page.getByTestId('case-row-e2e-missing-photo')).toHaveCount(0);

    await page.getByTestId('filter-portrait').click();
    await expect(page).toHaveURL(/filter=portrait/);
    await expect(page.getByTestId('case-row-e2e-portrait-case')).toBeVisible();
  });

  test('shows a find-photo link on cases that need one', async ({ page }) => {
    await loginAsEditor(page);
    await page.goto('/cases/e2e-missing-photo');
    await expect(page.getByTestId('find-friendly-photo')).toBeVisible();

    await page.goto('/cases/e2e-portrait-case');
    await expect(page.getByTestId('find-friendly-photo')).toHaveCount(0);
  });

  test('classifies the current photo and rejects a mugshot candidate', async ({ page }) => {
    await loginAsEditor(page);
    await page.goto('/friendly_photos/e2e-missing-photo');

    await expect(page.getByTestId('mugshot-flag').first()).toBeVisible();
    await expect(page.getByTestId('apply-photo')).toHaveCount(1);

    await page.getByTestId('avatar-kind-select').selectOption('mugshot');
    await clickTestId(page, 'update-photo-type');
    await expect(page.getByText('Marked the current photo as mugshot')).toBeVisible();

    await clickTestId(page, 'reject-photo');
    await expect(page.getByText('Rejected that candidate')).toBeVisible();
  });

  test('applies a reviewed portrait and leaves mugshots un-applicable', async ({ page }) => {
    await loginAsEditor(page);
    await page.goto('/friendly_photos/e2e-missing-photo');

    await expect(page.getByTestId('apply-photo')).toHaveCount(1);
    await expect(page.getByTestId('mugshot-flag').first()).toBeVisible();

    await clickTestId(page, 'apply-photo');
    await expect(page.getByText('Applied the selected portrait to this case.')).toBeVisible();
    await expect(page.getByText('Photo type:')).toContainText('Portrait');
    await expect(page.getByTestId('apply-photo')).toHaveCount(0);
    await expect(page.getByTestId('mugshot-flag').first()).toBeVisible();
  });

  test('searches Wikimedia through the stub and keeps mugshots un-applicable', async ({
    page,
  }) => {
    await loginAsEditor(page);
    await page.goto('/friendly_photos/e2e-missing-photo');

    await clickTestId(page, 'search-wikimedia');

    await expect(page.getByText(/Found \d+ images/)).toBeVisible();
    await expect(page.getByText('E2E family portrait')).toBeVisible();
    await expect(page.getByText('E2E booking mugshot')).toBeVisible();
    await expect(page.getByTestId('mugshot-flag').first()).toBeVisible();
    await expect(page.getByTestId('apply-photo')).toHaveCount(2);
  });
});

test.describe('Friendly photos mobile', () => {
  test('hides the desktop nav link until the menu is opened', async ({ page }, testInfo) => {
    test.skip(testInfo.project.name !== 'mobile-chrome', 'Mobile-only gap check');

    await loginAsEditor(page);
    await page.goto('/');

    const navLink = page.getByTestId('friendly-photos-nav');
    await expect(navLink).toBeHidden();
    await page.locator('.navbar-toggle').click();
    await expect(navLink).toBeVisible();
  });
});
