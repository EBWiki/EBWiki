# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::Rollback do
  let(:output) { StringIO.new }
  let(:input) { StringIO.new }
  let(:executor) do
    instance_double(Release::Rollback::CommandExecutor).tap do |dbl|
      allow(dbl).to receive(:call).and_return(execution_ok)
    end
  end
  let(:execution_ok) { Release::Rollback::CommandExecutor::ExecutionResult.new(success: true, message: 'ok') }

  around do |example|
    @env_snapshot = ENV.to_hash
    ENV['RELEASE_ROLLBACK_PLATFORM'] = 'heroku'
    ENV['HEROKU_APP_NAME'] = 'ebwiki-staging'
    ENV.delete('RAILWAY_SERVICE')
    example.run
  ensure
    ENV.replace(@env_snapshot)
  end

  it 'prints a dry-run plan by default' do
    result = described_class.run([], executor: executor, output: output, input: input)

    expect(result.success).to be(true)
    expect(output.string).to include('dry run')
    expect(output.string).to include('heroku releases:rollback -a ebwiki-staging')
    expect(executor).not_to have_received(:call)
  end

  it 'refuses to run without a Heroku app name' do
    ENV.delete('HEROKU_APP_NAME')

    result = described_class.run([], executor: executor, output: output, input: input)

    expect(result.success).to be(false)
    expect(output.string).to include('HEROKU_APP_NAME')
  end

  it 'refuses --execute in a non-interactive session without --yes' do
    input = StringIO.new
    allow(input).to receive(:tty?).and_return(false)

    result = described_class.run(['--execute'], executor: executor, output: output, input: input)

    expect(result.success).to be(false)
    expect(output.string).to include('--yes')
    expect(executor).not_to have_received(:call)
  end

  it 'cancels when the operator answers n' do
    input = StringIO.new("n\n")
    allow(input).to receive(:tty?).and_return(true)

    result = described_class.run(['--execute'], executor: executor, output: output, input: input)

    expect(result.success).to be(false)
    expect(output.string).to include('cancelled')
  end

  it 'executes commands when --execute and --yes are passed' do
    result = described_class.run(%w[--execute --yes], executor: executor, output: output, input: input)

    expect(result.success).to be(true)
    expect(executor).to have_received(:call).with(
      [Release::ShellCommand.new(
        argv: %w[heroku releases:rollback -a ebwiki-staging],
        description: 'heroku releases:rollback -a ebwiki-staging'
      )]
    )
  end

  it 'rejects unknown flags' do
    result = described_class.run(['--with-migration-down'], executor: executor, output: output, input: input)

    expect(result.success).to be(false)
    expect(output.string).to include('Unknown flag')
  end

  it 'refuses when both Heroku and Railway are configured' do
    ENV['RAILWAY_SERVICE'] = 'ebwiki'

    result = described_class.run([], executor: executor, output: output, input: input)

    expect(result.success).to be(false)
    expect(output.string).to include('Both Heroku and Railway')
  end

  it 'reports executor failure' do
    allow(executor).to receive(:call).and_return(
      Release::Rollback::CommandExecutor::ExecutionResult.new(success: false, message: 'Command failed')
    )

    result = described_class.run(%w[--execute --yes], executor: executor, output: output, input: input)

    expect(result.success).to be(false)
    expect(result.message).to include('Command failed')
  end

  context 'when Railway is configured' do
    around do |example|
      ENV['RELEASE_ROLLBACK_PLATFORM'] = 'railway'
      ENV['RAILWAY_SERVICE'] = 'ebwiki'
      ENV['RAILWAY_ENVIRONMENT'] = 'staging'
      ENV['RAILWAY_ROLLBACK_DEPLOYMENT_ID'] = 'dep-123'
      ENV.delete('HEROKU_APP_NAME')
      example.run
    end

    it 'plans a Railway GraphQL deploymentRollback' do
      described_class.run([], executor: executor, output: output, input: input)

      expect(output.string).to include('deploymentRollback')
      expect(output.string).to include('dep-123')
    end
  end

  it 'rejects an unsupported platform' do
    ENV['RELEASE_ROLLBACK_PLATFORM'] = 'flyio'

    result = described_class.run([], executor: executor, output: output, input: input)

    expect(result.success).to be(false)
    expect(output.string).to include('Unsupported platform')
  end
end
