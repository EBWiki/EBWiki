# frozen_string_literal: true

require 'rails_helper'
require 'yaml'

RSpec.describe 'Release smoke check workflow' do
  let(:workflow_path) { Rails.root.join('.github/workflows/release_smoke_check.yml') }
  let(:workflow) { YAML.safe_load(File.read(workflow_path), aliases: true) }

  let(:staging_secret_condition) do
    "(github.event.inputs.target == 'staging') && secrets.STAGING_USERNAME"
  end

  def workflow_triggers(doc)
    doc['on'] || doc[true]
  end

  def contract_satisfied?(doc)
    on = workflow_triggers(doc)
    return false unless on.is_a?(Hash) && on.keys == ['workflow_dispatch']

    job = doc.dig('jobs', 'smoke_check')
    return false unless job.is_a?(Hash)
    return false unless job['if'] == "github.ref == 'refs/heads/main'"
    return false unless job['environment'] == 'release-smoke'

    step = job.fetch('steps', []).find { |entry| entry['name'] == 'Run post-deploy smoke check' }
    return false unless step

    env = step['env'] || {}
    username = env['STAGING_USERNAME'].to_s
    password = env['STAGING_PASSWORD'].to_s
    return false unless username.include?(staging_secret_condition)
    return false unless password.include?("target == 'staging') && secrets.STAGING_PASSWORD")

    true
  end

  it 'satisfies the release-smoke workflow contract' do
    expect(contract_satisfied?(workflow)).to be(true)
  end

  {
    'workflow_dispatch-only trigger' => lambda { |doc|
      triggers = doc['on'] || doc[true]
      triggers['push'] = { 'branches' => ['main'] }
    },
    'main ref gate' => lambda { |doc|
      doc.dig('jobs', 'smoke_check')['if'] = 'true'
    },
    'release-smoke environment' => lambda { |doc|
      doc.dig('jobs', 'smoke_check').delete('environment')
    },
    'staging secret guard on STAGING_USERNAME' => lambda { |doc|
      step = doc.dig('jobs', 'smoke_check', 'steps').find { |s| s['name'] == 'Run post-deploy smoke check' }
      step['env']['STAGING_USERNAME'] = '${{ secrets.STAGING_USERNAME }}'
    },
    'staging secret guard on STAGING_PASSWORD' => lambda { |doc|
      step = doc.dig('jobs', 'smoke_check', 'steps').find { |s| s['name'] == 'Run post-deploy smoke check' }
      step['env']['STAGING_PASSWORD'] = '${{ secrets.STAGING_PASSWORD }}'
    }
  }.each do |label, mutation|
    it "fails the contract when #{label} is removed" do
      mutated = YAML.safe_load(YAML.dump(workflow), aliases: true)
      mutation.call(mutated)
      expect(contract_satisfied?(mutated)).to be(false)
    end
  end
end
