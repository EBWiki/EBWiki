# frozen_string_literal: true

require 'open3'

RSpec.describe 'bin/release-rollback CLI' do
  let(:root) { File.expand_path('../..', __dir__) }
  let(:bin) { File.join(root, 'bin/release-rollback') }
  let(:railway_env) do
    {
      'RELEASE_ROLLBACK_PLATFORM' => 'railway',
      'RAILWAY_SERVICE' => 'ebwiki',
      'RAILWAY_ENVIRONMENT' => 'staging',
      'RAILWAY_ROLLBACK_DEPLOYMENT_ID' => '11111111-2222-4333-8444-555555555555'
    }
  end

  def run_cli(args, env: {})
    env = ENV.to_hash.merge('BUNDLE_GEMFILE' => '').merge(env)
    Open3.capture3(env, 'ruby', bin, *args, chdir: root)
  end

  def expect_clean_subprocess(stderr)
    expect(stderr).not_to match(/NameError|NoMethodError|LoadError/)
  end

  it 'prints --help without loading Rails' do
    stdout, stderr, status = run_cli(%w[--help])

    expect(status).to be_success
    expect(stdout).to include('Usage: bin/release-rollback')
    expect(stderr).to be_empty
    expect_clean_subprocess(stderr)
  end

  it 'prints a Heroku dry-run plan without loading Rails' do
    stdout, stderr, status = run_cli([], env: { 'HEROKU_APP_NAME' => 'ebwiki-staging' })

    expect(status).to be_success
    expect(stdout).to include('dry run')
    expect(stdout).to include('heroku releases:rollback -a ebwiki-staging')
    expect(stderr).to be_empty
    expect_clean_subprocess(stderr)
  end

  it 'prints a missing RAILWAY_TOKEN message on execute' do
    _stdout, stderr, status = run_cli(%w[--execute --yes], env: railway_env)

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('Set RAILWAY_TOKEN')
    expect_clean_subprocess(stderr)
  end

  it 'prints a service mismatch message on execute' do
    stub = File.expand_path('railway_subprocess_service_mismatch.rb', __dir__)
    env = railway_env.merge(
      'RAILWAY_TOKEN' => 'token',
      'RUBYOPT' => "-r#{stub}"
    )

    _stdout, stderr, status = run_cli(%w[--execute --yes], env: env)

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('Deployment belongs to service "other-service", not "ebwiki".')
    expect_clean_subprocess(stderr)
  end

  it 'prints an environment mismatch message on execute' do
    stub = File.expand_path('railway_subprocess_environment_mismatch.rb', __dir__)
    env = railway_env.merge(
      'RAILWAY_TOKEN' => 'token',
      'RUBYOPT' => "-r#{stub}"
    )

    _stdout, stderr, status = run_cli(%w[--execute --yes], env: env)

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('Deployment belongs to environment "production", not "staging".')
    expect_clean_subprocess(stderr)
  end
end
