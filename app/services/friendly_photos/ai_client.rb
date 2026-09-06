# frozen_string_literal: true

module FriendlyPhotos
  # Minimal OpenAI / Anthropic HTTP client for planner and vision calls.
  class AiClient
    include HTTParty

    default_timeout ENV.fetch('FRIENDLY_PHOTOS_AI_TIMEOUT', 12).to_i

    OPENAI_URL = 'https://api.openai.com/v1/chat/completions'
    ANTHROPIC_URL = 'https://api.anthropic.com/v1/messages'

    def chat_json(system:, user:, image_url: nil)
      send_chat(system: system, user: user, image_url: image_url)
    rescue StandardError => e
      Rails.logger.error("[FriendlyPhotos::AiClient] #{e.class}: #{e.message}")
      Rollbar.error(e) if defined?(Rollbar)
      nil
    end

    private

    def send_chat(system:, user:, image_url:)
      case AiConfig.provider
      when :openai then openai_chat(system: system, user: user, image_url: image_url)
      when :anthropic then anthropic_chat(system: system, user: user, image_url: image_url)
      end
    end

    def openai_chat(system:, user:, image_url:)
      response = self.class.post(
        OPENAI_URL,
        headers: openai_headers,
        body: openai_body(system, user, image_url)
      )
      parse_json(response.dig('choices', 0, 'message', 'content')) if response.success?
    end

    def anthropic_chat(system:, user:, image_url:)
      response = self.class.post(
        ANTHROPIC_URL,
        headers: anthropic_headers,
        body: anthropic_body(system, user, image_url)
      )
      parse_json(anthropic_text(response)) if response.success?
    end

    def openai_headers
      {
        'Authorization' => "Bearer #{ENV.fetch('OPENAI_API_KEY')}",
        'Content-Type' => 'application/json'
      }
    end

    def anthropic_headers
      {
        'x-api-key' => ENV.fetch('ANTHROPIC_API_KEY'),
        'anthropic-version' => '2023-06-01',
        'Content-Type' => 'application/json'
      }
    end

    def openai_body(system, user, image_url)
      user_content = image_url ? vision_user_content(user, image_url) : user
      {
        model: AiConfig::OPENAI_MODEL,
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: system },
          { role: 'user', content: user_content }
        ],
        temperature: 0.2
      }.to_json
    end

    def anthropic_body(system, user, image_url)
      {
        model: AiConfig::ANTHROPIC_MODEL,
        max_tokens: 1024,
        system: system,
        messages: [{ role: 'user', content: anthropic_user_blocks(user, image_url) }],
        temperature: 0.2
      }.to_json
    end

    def anthropic_user_blocks(user, image_url)
      blocks = [{ type: 'text', text: user }]
      blocks << anthropic_image_block(image_url) if image_url.present?
      blocks
    end

    def anthropic_text(response)
      Array(response['content']).filter_map { |block| text_block(block) }.join
    end

    def text_block(block)
      block['text'] if block['type'] == 'text'
    end

    def vision_user_content(user, image_url)
      [
        { type: 'text', text: user },
        { type: 'image_url', image_url: { url: image_url } }
      ]
    end

    def anthropic_image_block(image_url)
      {
        type: 'image',
        source: { type: 'url', url: image_url }
      }
    end

    def parse_json(raw)
      return if raw.blank?

      JSON.parse(raw)
    rescue JSON::ParserError
      match = raw.match(/\{.*\}/m)
      match ? JSON.parse(match[0]) : nil
    end
  end
end
