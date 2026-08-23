#!/usr/bin/env ruby
# frozen_string_literal: true

# One public port in front of Rails and Hanami.
# GET / /cases /articles /search /agencies /about and the other public
# read paths go to Hanami. Everything else (login, writes, admin) goes to Rails.

require "net/http"
require "uri"
require "webrick"

HANAMI_URL = ENV.fetch("HANAMI_URL", "http://127.0.0.1:2300")
RAILS_URL = ENV.fetch("RAILS_URL", "http://127.0.0.1:3001")
PORT = Integer(ENV.fetch("PORT", "3000"))

HANAMI_PREFIXES = %w[
  /
  /cases
  /articles
  /search
  /agencies
  /about
  /guidelines
  /instructions
  /get-involved
  /how-to-help
].freeze

def hanami?(request)
  return false unless request.request_method == "GET" || request.request_method == "HEAD"

  path = request.path
  HANAMI_PREFIXES.any? { |prefix| path == prefix || path.start_with?("#{prefix}/") }
end

def forward(request, response, target)
  uri = URI.join(target, request.unparsed_uri)
  klass = request.request_method == "GET" || request.request_method == "HEAD" ? Net::HTTP::Get : Net::HTTP::Post
  upstream = klass.new(uri)
  request.each { |key, value| upstream[key] = value unless key.downcase == "host" }
  if request.body
    body = request.body
    upstream.body = body
    upstream.content_length = body.bytesize
  end

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == "https"
  result = http.request(upstream)

  response.status = result.code.to_i
  result.each_header do |key, value|
    next if %w[transfer-encoding connection].include?(key.downcase)

    response[key] = value
  end
  response.body = result.body
end

server = WEBrick::HTTPServer.new(Port: PORT, BindAddress: "0.0.0.0")
server.mount_proc "/" do |request, response|
  target = hanami?(request) ? HANAMI_URL : RAILS_URL
  forward(request, response, target)
rescue Errno::ECONNREFUSED
  response.status = 502
  response["Content-Type"] = "text/plain"
  response.body = "Upstream #{target} is not running. Start Rails on 3001 and Hanami on 2300."
end

trap("INT") { server.shutdown }
trap("TERM") { server.shutdown }

warn "One site on http://127.0.0.1:#{PORT} (Hanami reads → #{HANAMI_URL}, Rails writes → #{RAILS_URL})"
server.start
