# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::ErrorReporter do
  let(:logger) { instance_double(Logger, error: nil, warn: nil) }

  before do
    allow(Rails).to receive(:logger).and_return(logger)
    stub_const('Rollbar', Class.new do
      def self.error(*); end
    end)
    allow(Rollbar).to receive(:error)
  end

  it 'logs structured JSON and notifies Rollbar' do
    described_class.report(event: 'test_event', message: 'failure', context: { step: :home_page })

    expect(logger).to have_received(:error) do |payload|
      parsed = JSON.parse(payload)
      expect(parsed['event']).to eq('test_event')
      expect(parsed['message']).to eq('failure')
    end
    expect(Rollbar).to have_received(:error).with('failure', hash_including(event: 'test_event'))
  end
end
