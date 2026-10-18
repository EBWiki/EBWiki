# frozen_string_literal: true

require 'open3'

RSpec.describe 'bin/release-rollback CLI' do
  let(:root) { File.expand_path('../..', __dir__) }
  let(:bin) { File.join(root, 'bin/release-rollback') }
  let(:probe) { File.expand_path('probe_no_activesupport.rb', __dir__) }
  let(:railway_env) do
    {
      'RELEASE_ROLLBACK_PLATFORM' => 'railway',
      'RAILWAY_SERVICE' => 'ebwiki',
      'RAILWAY_ENVIRONMENT' => 'production',
      'RAILWAY_ROLLBACK_DEPLOYMENT_ID' => '11111111-2222-4333-8444-555555555555'
    }
  end

  def clean_env(overrides = {})
    base = {
      'PATH' => ENV.fetch('PATH', ''),
      'HOME' => ENV.fetch('HOME', '/tmp'),
      'BUNDLE_GEMFILE' => '',
      'RUBYOPT' => ''
    }
    merged = base.merge(overrides)
    %w[RAILWAY_TOKEN RAILWAY_API_TOKEN].each do |key|
      merged[key] = '' unless overrides.key?(key)
    end
    merged
  end

  def run_cli(args, env: {})
    Open3.capture3(clean_env(env), 'ruby', bin, *args, chdir: root)
  end

  def run_cli_without_rails(args, env: {})
    run_cli(args, env: env.merge('RUBYOPT' => "-r#{probe}"))
  end

  def expect_clean_subprocess(stderr)
    expect(stderr).not_to match(/NameError|NoMethodError|LoadError/)
  end

  def expect_no_activesupport_in_output(output)
    expect(output).to include('ACTIVESUPPORT=nil')
  end

  it 'prints --help without loading Rails' do
    stdout, stderr, status = run_cli_without_rails(%w[--help])

    expect(status).to be_success
    expect(stdout).to include('Usage: bin/release-rollback')
    expect(stderr).to be_empty
    expect_clean_subprocess(stderr)
    expect_no_activesupport_in_output(stdout)
  end

  it 'prints a Railway dry-run plan without loading Rails' do
    stdout, stderr, status = run_cli_without_rails([], env: railway_env)

    expect(status).to be_success
    expect(stdout).to include('dry run')
    expect(stdout).to include('deploymentRollback')
    expect(stderr).to be_empty
    expect_clean_subprocess(stderr)
    expect_no_activesupport_in_output(stdout)
  end

  it 'prints a missing RAILWAY_TOKEN message on execute' do
    env = railway_env.dup
    env.delete('RAILWAY_TOKEN')
    stdout, stderr, status = run_cli_without_rails(%w[--execute --yes], env: env)

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('Set RAILWAY_TOKEN')
    expect_clean_subprocess(stderr)
    expect_no_activesupport_in_output(stdout)
  end

  it 'prints a service mismatch message on execute' do
    stub = File.expand_path('railway_subprocess_service_mismatch.rb', __dir__)
    env = railway_env.merge(
      'RAILWAY_TOKEN' => 'token',
      'RUBYOPT' => "-r#{stub} -r#{probe}"
    )

    stdout, stderr, status = run_cli(%w[--execute --yes], env: env)

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('Deployment belongs to service "other-service", not "ebwiki".')
    expect_clean_subprocess(stderr)
    expect_no_activesupport_in_output(stdout)
  end

  it 'prints an environment mismatch message on execute' do
    stub = File.expand_path('railway_subprocess_environment_mismatch.rb', __dir__)
    env = railway_env.merge(
      'RAILWAY_ENVIRONMENT' => 'staging',
      'RAILWAY_TOKEN' => 'token',
      'RUBYOPT' => "-r#{stub} -r#{probe}"
    )

    stdout, stderr, status = run_cli(%w[--execute --yes], env: env)

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('Deployment belongs to environment "production", not "staging".')
    expect_clean_subprocess(stderr)
    expect_no_activesupport_in_output(stdout)
  end
end
