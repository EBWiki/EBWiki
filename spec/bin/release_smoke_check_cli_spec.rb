# frozen_string_literal: true

require 'open3'

RSpec.describe 'bin/release-smoke-check CLI' do
  let(:root) { File.expand_path('../..', __dir__) }
  let(:bin) { File.join(root, 'bin/release-smoke-check') }
  let(:probe) { File.expand_path('probe_no_activesupport.rb', __dir__) }

  def clean_env(overrides = {})
    {
      'PATH' => ENV.fetch('PATH', ''),
      'HOME' => ENV.fetch('HOME', '/tmp'),
      'BUNDLE_GEMFILE' => '',
      'RUBYOPT' => ''
    }.merge(overrides)
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
    expect(stdout).to include('Usage: bin/release-smoke-check')
    expect(stderr).to be_empty
    expect_clean_subprocess(stderr)
    expect_no_activesupport_in_output(stdout)
  end

  it 'exits 1 when the smoke check fails without loading Rails' do
    stdout, stderr, status = run_cli_without_rails(
      ['https://127.0.0.1'],
      env: {
        'RELEASE_SMOKE_SEARCH_TERM' => '*',
        'RELEASE_SMOKE_ALLOWED_HOSTS' => '127.0.0.1'
      }
    )

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('Release smoke check failed')
    expect_clean_subprocess(stderr)
    expect_no_activesupport_in_output(stdout)
  end

  it 'exits 1 for a non-allowlisted host without loading Rails' do
    stdout, stderr, status = run_cli_without_rails(['https://evil.example.com'])

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('not allowlisted')
    expect_clean_subprocess(stderr)
    expect_no_activesupport_in_output(stdout)
  end
end
