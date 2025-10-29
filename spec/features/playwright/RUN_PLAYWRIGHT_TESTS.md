# Running Playwright Tests in EBWiki

## Environment Setup

For Playwright tests, use the `ebwiki` gemset with a clean environment:

```bash
# Set up environment for ebwiki gemset only (no global gemset)
export GEM_HOME="/usr/share/rvm/gems/ruby-3.4.2@ebwiki"
export GEM_PATH="/usr/share/rvm/gems/ruby-3.4.2@ebwiki"
export PATH="${GEM_HOME}/bin:/usr/share/rvm/rubies/ruby-3.4.2/bin:/usr/share/rvm/bin:${PATH}"
```

## Running Tests

### Run All Playwright Specs (Headless)
```bash
bundle exec rspec spec/features/playwright
```

### Run All Playwright Specs (Headed - See Browser)
```bash
PLAYWRIGHT_HEADED=true bundle exec rspec spec/features/playwright
```

### Run Specific Spec File
```bash
bundle exec rspec spec/features/playwright/static_pages_spec.rb
```

### Run with Progress Output
```bash
bundle exec rspec spec/features/playwright --format progress
```

### Run with Documentation Output
```bash
bundle exec rspec spec/features/playwright --format documentation
```

## Current Test Status

- **Total Specs**: 55 examples across 8 spec files
- **Static Pages**: 10 examples, all passing ✓
- **Other Pages**: Some failures due to page-specific requirements (404s, missing content, etc.)

## Notes

- All specs use `js: true` to enable Playwright driver
- WebMock is configured to allow localhost connections for browser tests
- Tests run against a Capybara server on `127.0.0.1:3001`

