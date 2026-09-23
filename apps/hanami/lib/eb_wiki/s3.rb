# frozen_string_literal: true

require "cgi"
require "net/http"
require "openssl"
require "time"
require "uri"

module EbWiki
  # Minimal S3 PUT/DELETE using the same env vars as Rails CarrierWave/fog.
  class S3
    def self.configured?
      new.configured?
    end

    def self.put(key, body, content_type:)
      new.put(key, body, content_type: content_type)
    end

    def self.delete(key)
      new.delete(key)
    end

    def configured?
      !access_key.empty? && !secret.empty? && !bucket.empty? && !test_env?
    end

    def put(key, body, content_type:)
      request("PUT", key, body: body, content_type: content_type)
    end

    def delete(key)
      request("DELETE", key, body: "", content_type: "application/octet-stream")
    end

    private

    def request(method, key, body:, content_type:)
      return false unless configured?

      payload_hash = OpenSSL::Digest::SHA256.hexdigest(body)
      now = Time.now.utc
      amz_date = now.strftime("%Y%m%dT%H%M%SZ")
      datestamp = now.strftime("%Y%m%d")
      uri = URI(object_url(key))
      signed_headers = "content-type;host;x-amz-acl;x-amz-content-sha256;x-amz-date"
      canonical_headers = [
        "content-type:#{content_type}",
        "host:#{uri.host}",
        "x-amz-acl:public-read",
        "x-amz-content-sha256:#{payload_hash}",
        "x-amz-date:#{amz_date}",
        ""
      ].join("\n")
      canonical_request = [
        method,
        uri.path,
        "",
        canonical_headers,
        signed_headers,
        payload_hash
      ].join("\n")
      credential_scope = "#{datestamp}/#{region}/s3/aws4_request"
      string_to_sign = [
        "AWS4-HMAC-SHA256",
        amz_date,
        credential_scope,
        OpenSSL::Digest::SHA256.hexdigest(canonical_request)
      ].join("\n")
      signature = OpenSSL::HMAC.hexdigest("SHA256", signing_key(datestamp), string_to_sign)
      authorization = "AWS4-HMAC-SHA256 Credential=#{access_key}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"

      http = Net::HTTP.new(uri.host, 443)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 20
      req = (method == "DELETE") ? Net::HTTP::Delete.new(uri) : Net::HTTP::Put.new(uri)
      req["content-type"] = content_type
      req["host"] = uri.host
      req["x-amz-acl"] = "public-read"
      req["x-amz-content-sha256"] = payload_hash
      req["x-amz-date"] = amz_date
      req["authorization"] = authorization
      req.body = body unless method == "DELETE"
      response = http.request(req)
      return true if response.is_a?(Net::HTTPSuccess)

      warn "EbWiki::S3 #{method} #{key} failed: #{response.code}"
      false
    rescue => error
      warn "EbWiki::S3 #{method} #{key} failed: #{error.class}: #{error.message}"
      false
    end

    def object_url(key)
      path = key.split("/").map { |part| CGI.escape(part).gsub("+", "%20") }.join("/")
      "https://#{host}/#{path}"
    end

    def host
      (region == "us-east-1") ? "#{bucket}.s3.amazonaws.com" : "#{bucket}.s3.#{region}.amazonaws.com"
    end

    def signing_key(datestamp)
      key = hmac("AWS4#{secret}", datestamp)
      key = hmac(key, region)
      key = hmac(key, "s3")
      hmac(key, "aws4_request")
    end

    def hmac(key, data)
      OpenSSL::HMAC.digest("SHA256", key, data)
    end

    def access_key
      ENV["AWS_ACCESS_KEY_ID"].to_s
    end

    def secret
      value = ENV["AWS_SECRET_KEY_ID"].to_s
      value.empty? ? ENV["AWS_SECRET_ACCESS_KEY"].to_s : value
    end

    def bucket
      ENV["S3_BUCKET"].to_s
    end

    def region
      value = ENV["S3_REGION"].to_s
      value.empty? ? "us-east-1" : value
    end

    def test_env?
      return false if ENV["S3_TEST"] == "1"

      defined?(Hanami) && Hanami.env?(:test)
    end
  end
end
