# Browser Automation with Playwright in EBWiki

## Environment Setup

To run Playwright specs, you need to set up the Ruby environment correctly:

```bash
export GEM_HOME="/usr/share/rvm/gems/ruby-3.4.2@ebwiki"
export GEM_PATH="/usr/share/rvm/gems/ruby-3.4.2@ebwiki:/usr/share/rvm/gems/ruby-3.4.2@global"
export PATH="${GEM_HOME}/bin:/usr/share/rvm/gems/ruby-3.4.2@global/bin:/usr/share/rvm/rubies/ruby-3.4.2/bin:/usr/share/rvm/bin:${PATH}"
```

## Running Playwright Specs

### Headless Mode (Default)
```bash
bundle exec rspec spec/features/playwright
```

### Headed Mode (See Browser)
```bash
PLAYWRIGHT_HEADED=true bundle exec rspec spec/features/playwright
```

### Run Specific Spec File
```bash
bundle exec rspec spec/features/playwright/static_pages_spec.rb
```

### Run Specific Test
```bash
bundle exec rspec spec/features/playwright/static_pages_spec.rb:6
```

## Browser Automation Features

### Basic Capybara DSL

All Playwright specs use the standard Capybara DSL, which is available when using `js: true`:

```ruby
RSpec.describe 'My Feature', type: :feature, js: true do
  it 'does something' do
    visit root_path
    fill_in 'Email', with: 'user@example.com'
    click_button 'Submit'
    expect(page).to have_content('Success')
  end
end
```

### Taking Screenshots

Capybara automatically saves screenshots on failures. For manual screenshots:

```ruby
it 'takes a screenshot' do
  visit '/about'
  page.save_screenshot('about_page.png')
end
```

### Advanced Browser Interaction

```ruby
# Get page title
page.title

# Execute JavaScript
page.execute_script("alert('Hello')")

# Wait for elements to appear
expect(page).to have_css('.my-class', wait: 5)

# Check page status
expect(page.status_code).to eq(200)

# Check current URL
expect(page).to have_current_path('/expected/path')
```

### Form Interaction

```ruby
# Fill in fields
fill_in 'Email', with: 'user@example.com'
fill_in 'Password', with: 'password'

# Select from dropdown
select 'Option', from: 'Select Field'

# Check/uncheck boxes
check 'Agree to terms'
uncheck 'Newsletter'

# Choose radio button
choose 'Option A'

# Attach files
attach_file 'Avatar', '/path/to/file.jpg'

# Submit forms
click_button 'Submit'
# or
click_on 'Submit Link'
```

### Finding Elements

```ruby
# By text
expect(page).to have_content('Text content')
expect(page).to have_text('Text content')
expect(page).to have_link('Link Text')

# By CSS
expect(page).to have_css('.class-name')
expect(page).to have_css('#id-name')
find('.my-class').click

# By XPath
expect(page).to have_xpath("//div[@class='my-class']")
find(:xpath, "//div[@class='my-class']").click

# By label
expect(page).to have_field('Label Text')
expect(page).to have_field('input_name')
```

### Waiting and Async Operations

Playwright/Capybara automatically waits for elements, but you can also:

```ruby
# Wait for specific time (not recommended, use have_* matchers)
sleep 2

# Wait for element to appear
expect(page).to have_css('.async-content', wait: 10)

# Wait for JavaScript to execute
expect(page).to have_content('Loaded via JS', wait: 5)

# Use Capybara's built-in waiting
using_wait_time(10) do
  expect(page).to have_content('Slow content')
end
```

### Debugging

#### Pause Execution
```ruby
it 'debugs an issue' do
  visit root_path
  binding.pry  # Use pry to debug
  # or
  save_and_open_page  # Open page in browser (requires launchy gem)
end
```

#### Headed Mode for Debugging
```bash
PLAYWRIGHT_HEADED=true bundle exec rspec spec/features/playwright/my_spec.rb
```

#### Take Screenshots
```ruby
it 'debugs with screenshots' do
  visit root_path
  page.save_screenshot('debug.png')
  # Screenshots saved to tmp/capybara by default
end
```

### Network and Request Inspection

```ruby
# Check network activity (requires additional setup)
# Capybara + Playwright doesn't expose this directly, but you can:
page.driver.browser # Access underlying Playwright browser (advanced)
```

### Multiple Windows/Tabs

```ruby
# Open in new window (if triggered by JS)
within_window(page.driver.browser.windows.last) do
  expect(page).to have_content('New Window Content')
end
```

## Configuration

### Server Settings

Capybara server runs on:
- Host: `127.0.0.1`
- Port: `3001` (configurable via `Capybara.server_port`)

### Browser Options

Current configuration uses:
- Browser: Chromium
- Headless: true (unless `PLAYWRIGHT_HEADED=true`)
- Max Wait Time: 10 seconds

### Changing Browser

To use Firefox or WebKit, modify `spec/support/capybara.rb`:

```ruby
Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :firefox,  # or :webkit
    headless: ENV['PLAYWRIGHT_HEADED'].nil?
  )
end
```

## Examples

### Simple Page Visit
```ruby
it 'visits a page' do
  visit '/about'
  expect(page).to have_content('About')
end
```

### Form Submission
```ruby
it 'submits a form' do
  visit new_user_registration_path
  fill_in 'Email', with: 'test@example.com'
  fill_in 'Password', with: 'password123'
  fill_in 'Password confirmation', with: 'password123'
  click_button 'Sign up'
  expect(page).to have_content('Welcome')
end
```

### Asserting Multiple Elements
```ruby
it 'sees multiple cases' do
  visit root_path
  cases.each do |this_case|
    expect(page).to have_content(this_case.title)
  end
end
```

### Checking Links and Navigation
```ruby
it 'navigates via links' do
  visit root_path
  click_link 'About'
  expect(page).to have_current_path('/about')
end
```

## Troubleshooting

### WebMock Errors
WebMock is automatically configured to allow localhost connections for Playwright tests. If you see errors, ensure specs are tagged with `js: true`.

### Timeout Errors
Increase wait time:
```ruby
Capybara.default_max_wait_time = 15
```

### Browser Not Starting
Ensure Playwright browsers are installed:
```bash
npx playwright install chromium
```

### Environment Issues
Always ensure GEM_HOME and GEM_PATH are set correctly for the ebwiki gemset.

