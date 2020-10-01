# frozen_string_literal: true

Recaptcha.configure do |config|
  config.skip_verify_env.push('development')
end
