# frozen_string_literal: true

require 'yaml'

module FriendlyPhotosSampleSet
  extend WebMock::API

  MANIFEST_PATH = Rails.root.join('spec/fixtures/friendly_photos/sample_set/cases.yml')

  module_function

  def cases
    @cases ||= YAML.load_file(MANIFEST_PATH).fetch('cases')
  end

  def reset!
    @cases = nil
  end

  def seed!
    cases.map do |row|
      this_case = FactoryBot.create(
        :case,
        title: row.fetch('subject_name'),
        city: row.fetch('city'),
        date: Date.new(row.fetch('year'), 6, 15),
        avatar_kind: 'unclassified'
      )
      this_case.update_column(:slug, row.fetch('slug')) # rubocop:disable Rails/SkipsModelValidations
      FactoryBot.create(:subject, case: this_case, name: row.fetch('subject_name'))
      this_case
    end
  end

  def install_webmock!
    stub_commons!
    stub_wikipedia!
    stub_openverse!
  end

  def case_for_token(token)
    cases.find { |row| row.fetch('subject_name') == token }
  end

  def commons_body_for(token)
    row = case_for_token(token)
    return empty_commons unless row

    pages = Array(row['hits']).each_with_index.with_object({}) do |(hit, index), memo|
      next unless hit['provider'] == 'commons'

      memo[(index + 1).to_s] = commons_page(hit, token, index)
    end
    { query: { pages: pages } }
  end

  def wikipedia_search_body_for(token)
    row = case_for_token(token)
    wiki = Array(row&.fetch('hits', [])).find { |hit| hit['provider'] == 'wikipedia' }
    return { query: { search: [] } } unless wiki

    { query: { search: [{ title: wiki.fetch('title') }] } }
  end

  def wikipedia_image_body_for(title)
    row = cases.find do |entry|
      Array(entry['hits']).any? { |hit| hit['provider'] == 'wikipedia' && hit['title'] == title }
    end
    hit = Array(row&.fetch('hits', [])).find do |h|
      h['provider'] == 'wikipedia' && h['title'] == title
    end
    return { query: { pages: {} } } unless hit

    token = row.fetch('subject_name')
    image_path = image_path_for(hit, token, 0)
    {
      query: {
        pages: {
          '2' => {
            title: hit.fetch('title'),
            fullurl: "https://en.wikipedia.org/wiki/#{hit.fetch('title').tr(' ', '_')}",
            pageimage: hit.fetch('file'),
            original: { source: "https://upload.wikimedia.org/wikipedia/commons/#{image_path}" }
          }
        }
      }
    }
  end

  def openverse_body_for(token)
    row = case_for_token(token)
    results = Array(row&.fetch('hits', [])).each_with_index.filter_map do |hit, index|
      next unless hit['provider'] == 'openverse'

      openverse_result(hit, token, index)
    end
    { results: results }
  end

  def stub_commons!
    stub_request(:get, %r{\Ahttps://commons\.wikimedia\.org/w/api\.php})
      .to_return do |request|
        token = token_from_commons_request(request.uri)
        body = token ? commons_body_for(token) : empty_commons
        { status: 200, body: body.to_json, headers: json_headers }
      end
  end

  def stub_wikipedia!
    stub_request(:get, %r{\Ahttps://en\.wikipedia\.org/w/api\.php})
      .with(query: hash_including('list' => 'search'))
      .to_return do |request|
        token = token_from_query_param(request.uri, 'srsearch')
        body = token ? wikipedia_search_body_for(token) : { query: { search: [] } }
        { status: 200, body: body.to_json, headers: json_headers }
      end

    stub_request(:get, %r{\Ahttps://en\.wikipedia\.org/w/api\.php})
      .with(query: hash_including('prop' => 'pageimages|info'))
      .to_return do |request|
        title = token_from_query_param(request.uri, 'titles')
        body = title ? wikipedia_image_body_for(title) : { query: { pages: {} } }
        { status: 200, body: body.to_json, headers: json_headers }
      end
  end

  def stub_openverse!
    stub_request(:get, %r{\Ahttps://api\.openverse\.org/v1/images/})
      .to_return do |request|
        token = token_from_query_param(request.uri, 'q')
        body = token ? openverse_body_for(token) : { results: [] }
        { status: 200, body: body.to_json, headers: json_headers }
      end
  end

  def token_from_commons_request(uri)
    params = Rack::Utils.parse_query(URI(uri).query)
    gsrsearch = params['gsrsearch'].to_s
    matching_token(gsrsearch)
  end

  def token_from_query_param(uri, key)
    params = Rack::Utils.parse_query(URI(uri).query)
    matching_token(params[key].to_s)
  end

  def matching_token(haystack)
    cases.find { |row| haystack.include?(row.fetch('subject_name')) }&.fetch('subject_name')
  end

  def commons_page(hit, token, index)
    image_path = image_path_for(hit, token, index)
    description = description_for(hit)
    {
      title: hit.fetch('file'),
      imageinfo: [{
        url: "https://upload.wikimedia.org/wikipedia/commons/#{image_path}",
        thumburl: "https://upload.wikimedia.org/wikipedia/commons/thumb/#{image_path}",
        descriptionurl: "https://commons.wikimedia.org/wiki/#{hit.fetch('file')}",
        mime: 'image/jpeg',
        extmetadata: {
          LicenseShortName: { value: 'CC BY-SA 4.0' },
          Artist: { value: 'Sample set fixture' },
          ImageDescription: { value: description }
        }
      }]
    }
  end

  def openverse_result(hit, token, index)
    slug = token.parameterize
    image_path = "ov/#{slug}-#{index}.jpg"
    description = description_for(hit)
    {
      title: hit.fetch('title'),
      url: "https://live.staticflickr.com/65535/#{image_path}",
      foreign_landing_url: "https://www.flickr.com/photos/sample-set/#{slug}-#{index}",
      license: 'by-sa',
      license_version: '4.0',
      license_url: 'https://creativecommons.org/licenses/by-sa/4.0/',
      creator: 'Sample set fixture',
      source: 'flickr',
      attribution: description
    }
  end

  def description_for(hit)
    if hit['homonym']
      "Portrait of the novelist #{hit.fetch('title')}, 19th century"
    elsif hit['portrait']
      "Family photo portrait of #{hit.fetch('title')}"
    else
      "County jail booking photo #{hit.fetch('title')}"
    end
  end

  def image_path_for(_hit, token, index)
    slug = token.parameterize
    "gkt1101/#{slug}-#{index}.jpg"
  end

  def empty_commons
    { query: { pages: {} } }
  end

  def json_headers
    { 'Content-Type' => 'application/json' }
  end

  def none_found_message(candidates)
    applyable = candidates.count(&:applyable?)
    if candidates.empty?
      'None found: Wikimedia and Openverse returned no openly licensed images.'
    elsif applyable.zero?
      "None found: #{candidates.size} images were not healthy profile pictures " \
        'or could not be verified, so they cannot be applied.'
    end
  end

  def friendly_candidates_stored?(candidates)
    candidates.any? { |candidate| !candidate.likely_mugshot? }
  end

  def expectation_met?(row, candidates)
    case row.fetch('expectation')
    when 'friendly_found'
      friendly_candidates_stored?(candidates)
    when 'none_found'
      none_found_message(candidates).present?
    else
      raise "Unknown expectation #{row.fetch('expectation').inspect}"
    end
  end
end
