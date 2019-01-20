# frozen_string_literal: true

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/vcr'
  c.hook_into :webmock
end