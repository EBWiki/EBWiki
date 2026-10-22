# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Case photo change request POST', type: :request do
  let(:this_case) do
    create(:case).tap do |record|
      record.update!(
        photo_url: 'https://example.com/photos/victim.jpg',
        photo_status: :shown
      )
    end
  end

  describe 'POST /cases/:case_id/photo_change_request' do
    let(:params) do
      {
        case_photo_change_request: {
          request_type: 'remove',
          message: 'Please remove this image.',
          requester_contact: 'family@example.com'
        }
      }
    end

    before do
      post case_photo_change_request_path(this_case), params: params
    end

    it 'creates a private request record' do
      request_record = CasePhotoChangeRequest.last
      expect(request_record.case_id).to eq(this_case.id)
      expect(request_record.request_type).to eq('remove')
      expect(request_record.message).to include('remove')
      expect(request_record.requester_contact).to eq('family@example.com')
    end

    it 'does not expose the request on the public case page' do
      get case_path(this_case)
      expect(response.body).not_to include('family@example.com')
      expect(response.body).not_to include('Please remove this image.')
    end
  end
end
