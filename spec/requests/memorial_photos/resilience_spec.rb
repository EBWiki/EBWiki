# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Memorial photos resilience', type: :request do
  it 'returns not found when the feature is disabled' do
    allow(MemorialPhotos).to receive(:enabled?).and_return(false)

    get memorial_photos_path

    expect(response).to have_http_status(:not_found)
  end

  it 'renders an error state with retry when the query fails' do
    query = instance_double(MemorialPhotoGridQuery, call: nil)
    allow(MemorialPhotoGridQuery).to receive(:new).and_return(query)
    allow(query).to receive(:call).and_raise(MemorialPhotos::QueryError, 'boom')

    get memorial_photos_path, params: { q: 'anything' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('We could not load the memorial grid')
    expect(response.body).to include('Retry')
  end
end
