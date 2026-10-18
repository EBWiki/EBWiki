# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::RollbarSetup do
  around do |example|
    token = ENV['ROLLBAR_ACCESS_TOKEN']
    ENV['ROLLBAR_ACCESS_TOKEN'] = 'test-token'
    example.run
  ensure
    ENV['ROLLBAR_ACCESS_TOKEN'] = token
  end

  it 'configures Rollbar with use_async disabled when the gem is available' do
    captured_config = nil
    allow(Rollbar).to receive(:configure) do |&block|
      config = Rollbar::Configuration.new
      block.call(config)
      captured_config = config
    end

    described_class.configure!

    expect(captured_config.use_async).to be(false)
  end

  it 'logs a JSON warning and continues when rollbar is not installed' do
    allow(described_class).to receive(:require_rollbar).and_raise(LoadError, 'cannot load such file')

    expect do
      described_class.configure!
    end.to output(/"event":"rollbar_setup"/).to_stderr
  end
end
