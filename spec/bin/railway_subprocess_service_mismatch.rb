# frozen_string_literal: true

require 'json'
require 'net/http'

# Preload with RUBYOPT to stub Railway GraphQL HTTP during subprocess rollback tests.
module Release
  module RailwaySubprocessServiceMismatch
    module_function

    def install!
      return if @installed

      klass = Net::HTTP
      klass.define_singleton_method(:start) do |_host, _port = nil, **_opts, &block|
        http = klass.new('127.0.0.1', 443)
        http.define_singleton_method(:request) do |request|
          body = JSON.parse(request.body)
          query = body.fetch('query')
          payload = if query.include?('deploymentRollback')
                      { 'data' => { 'deploymentRollback' => true } }
                    else
                      {
                        'data' => {
                          'deployment' => {
                            'id' => '11111111-2222-4333-8444-555555555555',
                            'service' => { 'name' => 'other-service' },
                            'environment' => { 'name' => 'staging' }
                          }
                        }
                      }
                    end
          Struct.new(:body).new(payload.to_json)
        end
        block ? block.call(http) : http
      end
      @installed = true
    end
  end
end

Release::RailwaySubprocessServiceMismatch.install!
