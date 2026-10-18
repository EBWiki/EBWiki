# frozen_string_literal: true

require 'rails_helper'

describe 'release:smoke_check' do
  include_context 'rake'

  let(:smoke_bin) { File.expand_path('../../bin/release-smoke-check', Rails.root.join('lib/tasks')) }

  it 'delegates to bin/release-smoke-check and exits 0 on success' do
    allow(Release::SmokeCheckCli).to receive(:system).with(smoke_bin, 'https://staging.example.com').and_return(true)

    expect { subject.invoke('https://staging.example.com') }.to raise_error(SystemExit) do |error|
      expect(error.status).to eq(0)
    end
  end

  it 'delegates to bin/release-smoke-check and exits 1 on failure' do
    allow(Release::SmokeCheckCli).to receive(:system).with(smoke_bin, 'https://staging.example.com').and_return(false)

    expect { subject.invoke('https://staging.example.com') }.to raise_error(SystemExit) do |error|
      expect(error.status).to eq(1)
    end
  end
end
