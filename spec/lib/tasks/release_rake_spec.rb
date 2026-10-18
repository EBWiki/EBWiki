# frozen_string_literal: true

require 'rails_helper'

describe 'release:smoke_check' do
  include_context 'rake'

  let(:check) { instance_double(Release::SmokeCheck, call: true) }

  before do
    allow(Release::SmokeCheck).to receive(:new).and_return(check)
  end

  it 'exits 0 when the smoke check passes' do
    expect { subject.invoke('https://staging.example.com') }.to raise_error(SystemExit) do |error|
      expect(error.status).to eq(0)
    end
    expect(Release::SmokeCheck).to have_received(:new).with(base_url: 'https://staging.example.com')
  end

  it 'exits 1 when the smoke check fails' do
    allow(check).to receive(:call).and_return(false)

    expect { subject.invoke('https://staging.example.com') }.to raise_error(SystemExit) do |error|
      expect(error.status).to eq(1)
    end
  end
end
