# frozen_string_literal: true

require 'rails_helper'

hanami_root = Rails.root.join('apps/hanami')
$LOAD_PATH.unshift(hanami_root.join('lib').to_s)
require 'photos_app'

RSpec.describe 'Hanami photo search preview' do
  let(:app) { PhotosApp.new(root: hanami_root.to_s) }

  it 'HTML-escapes a script tag in the search query' do
    payload = '<script>alert(1)</script>'
    env = Rack::MockRequest.env_for("/photos/search?q=#{Rack::Utils.escape_query(payload)}")
    status, _headers, body = app.photos_search(env)

    expect(status).to eq(200)
    html = body.join
    expect(html).not_to include(payload)
    expect(html).to include('&lt;script&gt;alert(1)&lt;/script&gt;')
  end
end
