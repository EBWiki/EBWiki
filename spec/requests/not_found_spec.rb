# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Not found responses', type: :request do
  around do |example|
    previous = Rails.application.env_config['action_dispatch.show_exceptions']
    Rails.application.env_config['action_dispatch.show_exceptions'] = :rescuable
    example.run
  ensure
    Rails.application.env_config['action_dispatch.show_exceptions'] = previous
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
