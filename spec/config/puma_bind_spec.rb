# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Puma bind configuration' do
  let(:puma_config) { Rails.root.join('config/puma.rb').read }
  let(:procfile) { Rails.root.join('Procfile').read }

  it 'binds the web server to all IPv4 interfaces for Railway private networking' do
    expect(puma_config).to match(/bind\s+["']tcp:\/\/0\.0\.0\.0:#\{ENV\.fetch\('PORT', 3000\)\}["']/)
  end

  it 'documents the same bind in the Procfile web command' do
    expect(procfile).to include('-b tcp://0.0.0.0:${PORT:-3000}')
  end
end
