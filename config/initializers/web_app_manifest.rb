# frozen_string_literal: true

# Sprockets-only MIME registration; Propshaft serves static .webmanifest.
if Rails.application.config.assets.respond_to?(:configure)
  Rails.application.config.assets.configure do |env|
    env.register_mime_type('application/manifest+json', extensions: ['.webmanifest'])
  end
end
