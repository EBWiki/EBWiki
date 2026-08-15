// @ts-check
const { defineConfig, devices } = require('@playwright/test')
const { existsSync } = require('fs')

const baseURL = process.env.BASE_URL || 'http://127.0.0.1:3000'
const requestedChannel = process.env.PW_CHANNEL
const systemChrome = existsSync('/usr/bin/google-chrome')
// Prefer the Cloud Agent / host Chrome so we do not download browsers locally.
// CI installs Playwright's Chromium and should leave PW_CHANNEL unset.
const channel =
  requestedChannel ||
  (!process.env.CI && systemChrome ? 'chrome' : undefined)

module.exports = defineConfig({
  testDir: './e2e',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1,
  reporter: process.env.CI ? [['list'], ['html', { open: 'never' }]] : 'list',
  use: {
    baseURL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    ...(channel ? { channel } : {})
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] }
    }
  ]
})
