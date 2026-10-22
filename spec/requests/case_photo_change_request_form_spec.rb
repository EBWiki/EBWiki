# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Case photo change request GET form', type: :request do
  let(:this_case) do
    create(:case).tap do |record|
      record.update!(
        photo_url: 'https://example.com/photos/victim.jpg',
        photo_status: :shown
      )
    end
  end

  before { get new_case_photo_change_request_path(this_case) }

  it 'returns the form page' do
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Request removal or a different photo')
    expect(response.body).to include('Submit request')
  end
end

RSpec.describe 'Case photo change request invalid POST', type: :request do
  let(:this_case) do
    create(:case).tap do |record|
      record.update!(
        photo_url: 'https://example.com/photos/victim.jpg',
        photo_status: :shown
      )
    end
  end

  before do
    post case_photo_change_request_path(this_case),
         params: { case_photo_change_request: { message: 'Still here' } }
  end

  it 're-renders the form' do
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Request removal or a different photo')
    expect(response.body).to include('Submit request')
  end
end
