# frozen_string_literal: true

require 'rails_helper'
require 'yaml'

RSpec.describe 'CI workflow' do
  let(:workflow) { YAML.safe_load(File.read(Rails.root.join('.github/workflows/ci.yml')), aliases: true) }
  let(:triggers) { workflow['on'] || workflow[true] }

  it 'runs on pull requests' do
    expect(triggers).to have_key('pull_request')
  end

  it 'runs on pushes to main so Railway can wait for CI before deploying staging' do
    expect(triggers.dig('push', 'branches')).to eq(['main'])
  end

  it 'runs RSpec in the rspec job' do
    runs = workflow.dig('jobs', 'rspec', 'steps').filter_map { |step| step['run'] }
    expect(runs.join("\n")).to include('bundle exec rspec spec/')
  end
end
