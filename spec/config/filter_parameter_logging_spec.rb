# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'filter_parameter_logging' do
  it 'redacts family request contact and message fields' do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    filtered = filter.filter(
      case_photo_change_request: {
        requester_contact: 'synthetic-contact@example.com',
        message: 'synthetic private message',
        request_type: 'remove'
      }
    )

    payload = filtered[:case_photo_change_request]
    expect(payload[:requester_contact]).to eq('[FILTERED]')
    expect(payload[:message]).to eq('[FILTERED]')
    expect(payload[:request_type]).to eq('remove')
  end
end
