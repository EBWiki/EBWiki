# frozen_string_literal: true

if ENV['SEARCHBOX_URL']
  Searchkick.client = Elasticsearch::Client.new(url: ENV['SEARCHBOX_URL'], logs: true)
elsif Rails.env == 'test'
  Searchkick.client = Elasticsearch::Client.new(url: 'http://localhost:9200', logs: true)
elsif Rails.env == 'development'
  Searchkick.client = Elasticsearch::Client.new(url: 'http://localhost:9200', logs: true)
end
