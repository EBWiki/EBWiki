# frozen_string_literal: true

# Looks for ELASTICSEARCH_URL but will settle for SEARCHBOX_URL
selected_server_url = ENV['ELASTICSEARCH_URL'] ||
                      ENV['SEARCHBOX_URL'] ||
                      'http://localhost:9200'

Searchkick.client = Elasticsearch::Client.new(url: selected_server_url, logs: true)
