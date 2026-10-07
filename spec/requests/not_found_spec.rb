# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Not found responses', type: :request do
  around do |example|
    config = Rails.application.config
    previous_show = config.action_dispatch.show_exceptions
    previous_local = config.consider_all_requests_local
    config.action_dispatch.show_exceptions = :all
    config.consider_all_requests_local = false
    example.run
  ensure
    config.action_dispatch.show_exceptions = previous_show
    config.consider_all_requests_local = previous_local
  end

  it 'returns 404 for an unknown agency slug' do
    get '/agencies/not-a-real-agency'

    expect(response).to have_http_status(:not_found)
    expect(response.body).to match(/doesn't exist/i)
  end

  it 'returns 404 for an unknown case slug' do
    get '/cases/this-case-does-not-exist'

    expect(response).to have_http_status(:not_found)
    expect(response.body).to match(/doesn't exist/i)
  end

  it 'returns 404 for an unknown organization' do
    get '/organizations/999999'

    expect(response).to have_http_status(:not_found)
    expect(response.body).to match(/doesn't exist/i)
  end

  it 'returns 404 for an unknown user' do
    get '/users/999999'

    expect(response).to have_http_status(:not_found)
    expect(response.body).to match(/doesn't exist/i)
  end

  it 'returns 404 for an unknown route' do
    get '/this-page-is-not-a-real-route'

    expect(response).to have_http_status(:not_found)
    expect(response.body).to match(/doesn't exist/i)
  end
end
