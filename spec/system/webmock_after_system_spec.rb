# frozen_string_literal: true

require 'rails_helper'
require 'net/http'

RSpec.describe 'WebMock after system examples', type: :system, order: :defined do
  it 'runs a system example so Capybara hooks execute' do
    visit root_path
    expect(page).to have_current_path(root_path, ignore_query: true)
  end

  it 'blocks non-localhost HTTP after system teardown' do
    expect do
      Net::HTTP.get(URI('https://example.com/'))
    end.to raise_error(WebMock::NetConnectNotAllowedError)
  end
end
