# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::UrlSanitizer do
  it 'strips userinfo from URLs used in logs' do
    expect(described_class.for_log('https://user:secret@staging.example.com/')).to eq('https://staging.example.com')
  end
end
