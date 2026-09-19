# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#link_to_http_url' do
    it 'links http and https URLs' do
      expect(helper.link_to_http_url('https://example.com')).to include('href="https://example.com"')
    end

    it 'does not turn a javascript URL into a link' do
      expect(helper.link_to_http_url('javascript:alert(1)')).to eq('javascript:alert(1)')
    end
  end
end
