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
    ->(env) { dispatch(app, env) }
  end

  def self.dispatch(app, env)
    path = Rack::Request.new(env).path_info
    handler = {
      '/health' => -> { app.health },
      '/photos' => -> { app.photos_index(env) },
      '/photos/search' => -> { app.photos_search(env) },
      '/photos/similar' => -> { app.photos_similar(env) },
      '/' => -> { app.rack_redirect('/photos') }
    }[path]
    handler ? handler.call : not_found
  end

  def self.not_found
    [404, { 'content-type' => 'text/plain' }, ['Not Found']]
  end
  private_class_method :not_found
end
