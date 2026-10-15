# frozen_string_literal: true

require 'erb'
require_relative 'html_escape'
require_relative 'demo_catalog'
require_relative 'photo_router'
require_relative 'vector_search'

class PhotosApp
  PageView = Data.define(:cases, :mode, :query, :anchor, :results, :semantic_ids)

  def initialize(root:)
    @root = root
    @cases = DemoCatalog.load(root: root)
    # Hanami preview runs without ActiveSupport; plain Ruby to_h keeps boot working.
    @by_id = @cases.to_h { |c| [c.id, c] } # rubocop:disable Rails/IndexBy
    @layout = ERB.new(File.read(File.join(root, 'views', 'layout.erb')))
    @index = ERB.new(File.read(File.join(root, 'views', 'index.erb')))
    @app = PhotoRouter.build(self, root: root)
  end

  # Explicit wrapper: Hanami preview has no ActiveSupport delegate helper loaded.
  def call(env) # rubocop:disable Rails/Delegate
    @app.call(env)
  end

  def health
    rack_response(200, 'OK', 'text/plain')
  end

  def photos_index(_env)
    render_page(grid_view)
  end

  def photos_search(env)
    render_page(search_view(Rack::Request.new(env).params['q'].to_s))
  end

  def photos_similar(env)
    photo_id = Rack::Request.new(env).params['photo_id'].to_i
    return rack_response(404, 'Unknown photo', 'text/plain') unless @by_id.key?(photo_id)

    render_page(similar_view(photo_id))
  end

  def rack_redirect(location)
    [302, { 'location' => location, 'content-type' => 'text/html' }, []]
  end

  private

  def grid_view
    PageView.new(
      cases: @cases, mode: 'grid', query: nil, anchor: nil, results: nil, semantic_ids: []
    )
  end

  def search_view(query)
    PageView.new(
      cases: @cases,
      mode: 'text_search',
      query: query,
      anchor: nil,
      results: DemoCatalog.text_match(@cases, query),
      semantic_ids: semantic_rank(query)
    )
  end

  def similar_view(photo_id)
    PageView.new(
      cases: @cases,
      mode: 'similar',
      query: nil,
      anchor: @by_id[photo_id],
      results: similar_neighbors(photo_id),
      semantic_ids: []
    )
  end

  def similar_neighbors(photo_id)
    VectorSearch
      .nearest(@by_id.transform_values(&:embedding), probe_id: photo_id, limit: 6)
      .map { |id, dist| [@by_id[id], dist] }
  end

  def semantic_rank(query)
    return [] if query.strip.empty?

    probe = VectorSearch.probe_from_text(query, dim: DemoCatalog::VECTOR_DIM)
    VectorSearch
      .nearest(@by_id.transform_values(&:embedding), probe_vector: probe, limit: 6)
      .map(&:first)
  end

  def render_page(view)
    html = @layout.result_with_hash(content: index_html(view))
    rack_response(200, html, 'text/html')
  end

  def index_html(view)
    @index.result_with_hash(
      cases: view.cases,
      mode: view.mode,
      query: view.query,
      anchor: view.anchor,
      results: view.results,
      semantic_ids: view.semantic_ids
    )
  end

  def rack_response(status, body, content_type)
    [status, { 'content-type' => "#{content_type}; charset=utf-8" }, [body]]
  end
end
