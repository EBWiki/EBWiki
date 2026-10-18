# frozen_string_literal: true

require 'open3'

RSpec.describe 'bin/release-rollback CLI' do
  let(:root) { File.expand_path('../..', __dir__) }
  let(:bin) { File.join(root, 'bin/release-rollback') }

  def run_cli(args, env: {})
    env = ENV.to_hash.merge('BUNDLE_GEMFILE' => '').merge(env)
    Open3.capture3(env, 'ruby', bin, *args, chdir: root)
  end

  it 'prints --help without loading Rails' do
    stdout, stderr, status = run_cli(%w[--help])

    expect(status).to be_success
    expect(stdout).to include('Usage: bin/release-rollback')
    expect(stderr).to be_empty
  end

  it 'prints a Heroku dry-run plan without loading Rails' do
    stdout, stderr, status = run_cli([], env: { 'HEROKU_APP_NAME' => 'ebwiki-staging' })

    expect(status).to be_success
    expect(stdout).to include('dry run')
    expect(stdout).to include('heroku releases:rollback -a ebwiki-staging')
    expect(stderr).to be_empty
  end
end
