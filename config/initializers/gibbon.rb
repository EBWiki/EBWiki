# frozen_string_literal: true

Gibbon::Request.api_key = ENV.fetch('MAILCHIMP_API_KEY', nil)
Gibbon::Request.timeout = 15
Gibbon::Request.throws_exceptions = false
