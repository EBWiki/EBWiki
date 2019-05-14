# frozen_string_literal: true

describe 'get /articles' do
  it 'redirects to cases' do
    get '/articles'
    expect(response).to redirect_to('/cases')
  end
end

describe 'get /articles/1' do
  it 'redirects to cases' do
    get '/articles/1'
    expect(response).to redirect_to('/cases/1')
  end
end

describe 'post /articles/1' do
  it 'redirects to cases' do
    post '/articles/1'
    expect(response).to redirect_to('/cases/1')
  end
end

describe 'put /articles/1' do
  it 'redirects to cases' do
    put '/articles/1'
    expect(response).to redirect_to('/cases/1')
  end
end

describe 'patch /articles/1' do
  it 'redirects to cases' do
    patch '/articles/1'
    expect(response).to redirect_to('/cases/1')
  end
end

describe 'delete /articles/1' do
  it 'redirects to cases' do
    delete '/articles/1'
    expect(response).to redirect_to('/cases/1')
  end
end
