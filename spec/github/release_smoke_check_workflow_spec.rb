# frozen_string_literal: true

require 'rails_helper'
require 'open3'
require 'yaml'

RSpec.describe 'Release smoke check workflow' do
  SMOKE_STEP = 'Run post-deploy smoke check'
  REQUIRE_STEP = 'Require release-smoke secrets'
  SECRET_NAMES = %w[STAGING_USERNAME STAGING_PASSWORD ROLLBAR_ACCESS_TOKEN].freeze

  let(:workflow_path) { Rails.root.join('.github/workflows/release_smoke_check.yml') }
  let(:workflow) { YAML.safe_load(File.read(workflow_path), aliases: true) }

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
    return false unless job.dig('env', 'RELEASE_SMOKE_BASE_URL') == 'https://staging.ebwiki.org'

    steps = job.fetch('steps', [])
    smoke_index = steps.index { |entry| entry['name'] == SMOKE_STEP }
    require_index = steps.index { |entry| entry['name'] == REQUIRE_STEP }
    return false unless smoke_index && require_index && require_index < smoke_index
    return false unless secrets_mapped?(steps[require_index]['env'])

    env = steps[smoke_index]['env'] || {}
    return false unless secrets_mapped?(env)
    return false unless env['ROLLBAR_ENV'] == 'staging'

    true
  end

  def secrets_mapped?(env)
    env ||= {}
    SECRET_NAMES.all? { |name| env[name] == "${{ secrets.#{name} }}" }
  end

  def run_require_step(env)
    step = workflow.dig('jobs', 'smoke_check', 'steps').find { |s| s['name'] == REQUIRE_STEP }
    Open3.capture3(env, 'bash', '-e', '-c', step.fetch('run'), unsetenv_others: true)
  end

  it 'fails the secrets step when any release-smoke secret is empty' do
    full = SECRET_NAMES.to_h { |name| [name, "#{name.downcase}-value"] }.merge('PATH' => ENV.fetch('PATH'))
    SECRET_NAMES.each do |name|
      _out, err, status = run_require_step(full.merge(name => ''))
      expect(status.success?).to be(false), "#{name} empty must fail"
      expect(err).to include(%("secret":"#{name}"))
    end
  end

  it 'passes the secrets step when every release-smoke secret is set' do
    full = SECRET_NAMES.to_h { |name| [name, "#{name.downcase}-value"] }.merge('PATH' => ENV.fetch('PATH'))
    _out, err, status = run_require_step(full)
    expect(status.success?).to be(true), err
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
    'staging base URL' => lambda { |doc|
      doc.dig('jobs', 'smoke_check', 'env').delete('RELEASE_SMOKE_BASE_URL')
    },
    'staging Rollbar environment' => lambda { |doc|
      step = doc.dig('jobs', 'smoke_check', 'steps').find { |s| s['name'] == 'Run post-deploy smoke check' }
      step['env']['ROLLBAR_ENV'] = 'production'
    },
    'staging credentials on STAGING_USERNAME' => lambda { |doc|
      step = doc.dig('jobs', 'smoke_check', 'steps').find { |s| s['name'] == 'Run post-deploy smoke check' }
      step['env']['STAGING_USERNAME'] = ''
    },
    'Rollbar token on the smoke step' => lambda { |doc|
      step = doc.dig('jobs', 'smoke_check', 'steps').find { |s| s['name'] == 'Run post-deploy smoke check' }
      step['env'].delete('ROLLBAR_ACCESS_TOKEN')
    },
    'required secrets step' => lambda { |doc|
      doc.dig('jobs', 'smoke_check', 'steps').reject! { |s| s['name'] == 'Require release-smoke secrets' }
    },
    'required secrets step order' => lambda { |doc|
      steps = doc.dig('jobs', 'smoke_check', 'steps')
      step = steps.find { |s| s['name'] == 'Require release-smoke secrets' }
      steps.delete(step)
      steps.push(step)
    },
    'Rollbar token on the required secrets step' => lambda { |doc|
      step = doc.dig('jobs', 'smoke_check', 'steps').find { |s| s['name'] == 'Require release-smoke secrets' }
      step['env'].delete('ROLLBAR_ACCESS_TOKEN')
    }
  }.each do |label, mutation|
    it "fails the contract when #{label} is removed" do
      mutated = YAML.safe_load(YAML.dump(workflow), aliases: true)
      mutation.call(mutated)
      expect(contract_satisfied?(mutated)).to be(false)
    end
  end
end
