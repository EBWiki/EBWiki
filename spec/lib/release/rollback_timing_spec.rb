# frozen_string_literal: true

require 'rails_helper'
require 'open3'

RSpec.describe 'Release rollback dry-run timing' do
  let(:root) { Rails.root }
  let(:bin) { root.join('bin/release-rollback') }

  it 'plans rollback within the staging-safe harness budget' do
    env = {
      'RAILWAY_ROLLBACK_DEPLOYMENT_ID' => '11111111-2222-4333-8444-555555555555',
      'RAILWAY_TOKEN' => 'token',
      'PATH' => ENV.fetch('PATH', ''),
      'HOME' => ENV.fetch('HOME', '/tmp')
    }
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    stdout, _stderr, status = Open3.capture3(env, 'ruby', bin.to_s, chdir: root.to_s)
    elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round

    expect(status).to be_success
    expect(stdout).to include('dry run')
    expect(elapsed_ms).to be < 5000
    warn "rollback dry-run harness: #{elapsed_ms}ms"
  end
end
