# frozen_string_literal: true

require 'rails_helper'
require 'psych'

RSpec.describe 'config/newrelic.yml' do
  let(:path) { Rails.root.join('config/newrelic.yml') }

  it 'loads with safe_load without YAML aliases (Psych 4 default)' do
    doc = Psych.safe_load(File.read(path), permitted_classes: [Symbol], aliases: false)
    expect(doc.fetch('staging')['app_name']).to eq('EBWiki (Staging)')
  end

  it 'loads with aliases enabled the way legacy agents parsed the file' do
    doc = Psych.safe_load(File.read(path), permitted_classes: [Symbol], aliases: true)
    expect(doc).to include('production', 'staging', 'test', 'development')
  end
end
