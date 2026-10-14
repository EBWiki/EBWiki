# frozen_string_literal: true

require 'erb'
require_relative 'demo_catalog'
require_relative 'vector_search'

class PhotosApp
  def initialize(root:)
    @root = root
    @cases = DemoCatalog.load(root: root)
    @by_id = @cases.each_with_object({}) { |c, h| h[c.id] = c }
    @layout = ERB.new(File.read(File.join(root, 'views', 'layout.erb')))
    @index = ERB.new(File.read(File.join(root, 'views', 'index.erb')))
    @app = build_app
  end

  def call(env)
    @app.call(env)
  end

  def health
    rack_response(200, 'OK', 'text/plain')
  end

  def photos_index(_env)
    render_index(cases: @cases, mode: 'grid', query: nil, anchor: nil, results: nil, semantic_ids: [])
  end

  def photos_search(env)
    req = Rack::Request.new(env)
    query = req.params['q'].to_s
    matched = DemoCatalog.text_match(@cases, query)
    semantic_ids = semantic_rank(query)
    render_index(
      cases: @cases,
      mode: 'text_search',
      query: query,
      anchor: nil,
      results: matched,
      semantic_ids: semantic_ids
    )
  end

  def photos_similar(env)
    req = Rack::Request.new(env)
    photo_id = req.params['photo_id'].to_i
    return rack_response(404, 'Unknown photo', 'text/plain') unless @by_id.key?(photo_id)

    neighbors = VectorSearch.nearest(
      @by_id.transform_values(&:embedding),
      probe_id: photo_id,
      limit: 6
    )
    neighbor_cases = neighbors.map { |id, dist| [@by_id[id], dist] }
    render_index(
      cases: @cases,
      mode: 'similar',
      query: nil,
      anchor: @by_id[photo_id],
      results: neighbor_cases,
      semantic_ids: []
    )
  end

  def rack_redirect(location)
    [302, { 'location' => location, 'content-type' => 'text/html' }, []]
  end

  private

  def build_app
    app = self
    routes = Hanami::Router.new do
      get '/health', to: ->(_env) { app.health }
      get '/photos', to: ->(env) { app.photos_index(env) }
      get '/photos/search', to: ->(env) { app.photos_search(env) }
      get '/photos/similar', to: ->(env) { app.photos_similar(env) }
      root to: ->(_env) { app.rack_redirect('/photos') }
    end

    Rack::Builder.new do
      use Rack::Static, urls: ['/placeholders', '/preview.css'], root: app.instance_variable_get(:@root)
      run routes
    end
  end

  def semantic_rank(query)
    return [] if query.strip.empty?

    probe = VectorSearch.probe_from_text(query, dim: DemoCatalog::VECTOR_DIM)
    VectorSearch
      .nearest(@by_id.transform_values(&:embedding), probe_vector: probe, limit: 6)
      .map(&:first)
  end

  def render_index(cases:, mode:, query:, anchor:, results:, semantic_ids:)
    html = @layout.result_with_hash(
      content: @index.result_with_hash(
        cases: cases,
        mode: mode,
        query: query,
        anchor: anchor,
        results: results,
        semantic_ids: semantic_ids
      )
    )
    rack_response(200, html, 'text/html')
  end

  def rack_response(status, body, content_type)
    [status, { 'content-type' => "#{content_type}; charset=utf-8" }, [body]]
  end

end
