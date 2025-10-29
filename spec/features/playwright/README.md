# Playwright Specs for Public Pages

This directory contains Playwright-powered browser tests for all public pages in EBWiki that don't require authentication.

## Overview

These specs use Capybara with the Playwright driver (configured via `js: true` tag) to test pages in a real browser environment. Playwright provides more reliable and faster browser automation compared to Selenium WebDriver.

## Spec Files

### `static_pages_spec.rb`
Tests for static information pages:
- `/about` - About page
- `/guidelines` - Guidelines page
- `/instructions` - Instructions page
- `/get-involved` - Get Involved page
- `/how-to-help` - How to Help page

### `cases_pages_spec.rb`
Tests for case-related pages:
- `/` (root) - Cases index (home page)
- `/cases` - Cases index
- `/cases/:slug` - Case show page
- `/cases/:slug/history` - Case history page
- `/cases/:slug/followers` - Case followers page

### `agencies_pages_spec.rb`
Tests for agency pages:
- `/agencies` - Agencies index
- `/agencies/:id` - Agency show page

### `organizations_pages_spec.rb`
Tests for organization pages:
- `/organizations` - Organizations index
- `/organizations/:id` - Organization show page

### `maps_pages_spec.rb`
Tests for map pages:
- `/maps` - Maps index

### `search_pages_spec.rb`
Tests for search functionality:
- `/search` - Search page
- `/search?query=...` - Search with query
- `/search?state_id=...` - Search with state filter

### `user_pages_spec.rb`
Tests for user profile pages:
- `/users/:id` - User show page (public profile)

### `authentication_pages_spec.rb`
Tests for authentication pages:
- `/users/sign_in` - Sign in page
- `/users/sign_up` - Registration page
- `/users/password/new` - Forgot password page

## Running the Specs

Run all Playwright specs:
```bash
bundle exec rspec spec/features/playwright
```

Run a specific spec file:
```bash
bundle exec rspec spec/features/playwright/static_pages_spec.rb
```

Run with visible browser (for debugging):
```bash
PLAYWRIGHT_HEADED=true bundle exec rspec spec/features/playwright
```

## Configuration

The Playwright driver is configured in `spec/support/capybara.rb`:
- Uses Chromium browser by default
- Runs in headless mode (set `PLAYWRIGHT_HEADED=true` to see browser)
- Configured as JavaScript driver for specs tagged with `js: true`

## Notes

- All specs use `js: true` to enable Playwright driver
- Specs use FactoryBot to create test data
- Each spec tests page loading and content display
- Tests are designed to be fast and reliable

