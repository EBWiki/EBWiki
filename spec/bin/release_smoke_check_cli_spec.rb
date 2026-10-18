# frozen_string_literal: true

require 'open3'

RSpec.describe 'bin/release-smoke-check CLI' do
  let(:root) { File.expand_path('../..', __dir__) }
  let(:bin) { File.join(root, 'bin/release-smoke-check') }

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
    expect(stdout).to include('Usage: bin/release-smoke-check')
    expect(stderr).to be_empty
    expect_clean_subprocess(stderr)
  end

  it 'exits 1 when the smoke check fails without loading Rails' do
    _stdout, stderr, status = run_cli(
      ['http://127.0.0.1:1'],
      env: { 'RELEASE_SMOKE_SEARCH_TERM' => '*' }
    )

    expect(status.exitstatus).to eq(1)
    expect(stderr).to include('Release smoke check failed')
    expect_clean_subprocess(stderr)
  end
end
