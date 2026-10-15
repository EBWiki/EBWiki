# frozen_string_literal: true

class PhotoRouter
  def self.build(app, root:)
    routes = routes_for(app)
    Rack::Builder.new do
      use Rack::Static, urls: ['/placeholders', '/preview.css'], root: root
      run routes
    end
  end

  def self.routes_for(app)
    Hanami::Router.new do
      get '/health', to: ->(_env) { app.health }
      get '/photos', to: ->(env) { app.photos_index(env) }
      get '/photos/search', to: ->(env) { app.photos_search(env) }
      get '/photos/similar', to: ->(env) { app.photos_similar(env) }
      root to: ->(_env) { app.rack_redirect('/photos') }
    end
  end
end
