# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::Rollback do
  let(:output) { StringIO.new }
  let(:executor) do
    instance_double(Release::Rollback::CommandExecutor).tap do |dbl|
      allow(dbl).to receive(:call).and_return(execution_ok)
    end
  end
  let(:execution_ok) { Release::Rollback::CommandExecutor::ExecutionResult.new(success: true, message: 'ok') }

  around do |example|
    original_heroku = ENV.fetch('HEROKU_APP_NAME', nil)
    original_platform = ENV.fetch('RELEASE_ROLLBACK_PLATFORM', nil)
    ENV['RELEASE_ROLLBACK_PLATFORM'] = 'heroku'
    ENV['HEROKU_APP_NAME'] = 'ebwiki-staging'
    example.run
  ensure
    restore_env('HEROKU_APP_NAME', original_heroku)
    restore_env('RELEASE_ROLLBACK_PLATFORM', original_platform)
  end

  it 'prints a dry-run plan by default' do
    result = described_class.run([], executor: executor, output: output)

    expect(result.success).to be(true)
    expect(output.string).to include('dry run')
    expect(output.string).to include('heroku releases:rollback -a ebwiki-staging')
    expect(executor).not_to have_received(:call)
  end

  it 'refuses to run without a Heroku app name' do
    ENV.delete('HEROKU_APP_NAME')

    result = described_class.run([], executor: executor, output: output)

    expect(result.success).to be(false)
    expect(output.string).to include('HEROKU_APP_NAME')
  end

  it 'executes commands when --execute and --yes are passed' do
    result = described_class.run(%w[--execute --yes], executor: executor, output: output)

    expect(result.success).to be(true)
    expect(executor).to have_received(:call).with(['heroku releases:rollback -a ebwiki-staging'])
  end

  it 'includes a migration rollback command when --with-migration-down is set' do
    described_class.run(%w[--execute --yes --with-migration-down], executor: executor, output: output)

    expect(executor).to have_received(:call).with(
      [
        'heroku run rake db:rollback STEP=1 -a ebwiki-staging',
        'heroku releases:rollback -a ebwiki-staging'
      ]
    )
  end

  context 'when Railway is configured' do
    around do |example|
      ENV['RELEASE_ROLLBACK_PLATFORM'] = 'railway'
      ENV['RAILWAY_SERVICE'] = 'ebwiki-web'
      ENV['RAILWAY_ROLLBACK_DEPLOYMENT_ID'] = 'dep-123'
      ENV.delete('HEROKU_APP_NAME')
      example.run
    end

    it 'plans a Railway redeploy to the previous deployment id' do
      described_class.run([], executor: executor, output: output)

      expect(output.string).to include('railway redeploy --deployment dep-123 --service ebwiki-web')
    end
  end

  def restore_env(key, value)
    if value.nil?
      ENV.delete(key)
    else
      ENV[key] = value
    end
  end
end
