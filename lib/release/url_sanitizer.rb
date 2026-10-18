# frozen_string_literal: true

require 'uri'

module Release
  # Removes credentials from URLs before logging.
  module UrlSanitizer
    module_function

    def for_log(url)
      uri = URI.parse(url.to_s)
      uri.user = nil
      uri.password = nil
      uri.to_s.chomp('/')
    rescue URI::InvalidURIError
      '[invalid-url]'
    end
  end
end
