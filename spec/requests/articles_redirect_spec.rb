# frozen_string_literal: true

RSpec.describe 'Article redirects' do
  let(:this_case) { FactoryBot.create(:case) }

  it 'redirects for the index action' do
    get '/articles'
    expect(response).to redirect_to('/cases')
  end

  it 'redirects for the show action' do
    get "/articles/#{this_case.slug}"
    expect(response).to redirect_to("/cases/#{this_case.slug}")
  end

  it 'redirects for the followers action' do
    get "/articles/#{this_case.slug}/followers"
    expect(response).to redirect_to("/cases/#{this_case.slug}/followers")
  end
end
