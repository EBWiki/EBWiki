# frozen_string_literal: true

module FriendlyPhotos
  # Minimal OpenAI / Anthropic HTTP client for planner and vision calls.
  class AiClient
    include HTTParty
    default_timeout 20

    OPENAI_URL = 'https://api.openai.com/v1/chat/completions'
    ANTHROPIC_URL = 'https://api.anthropic.com/v1/messages'

    def chat_json(system:, user:, image_url: nil)
      case AiConfig.provider
      when :openai
        openai_chat(system: system, user: user, image_url: image_url)
      when :anthropic
        anthropic_chat(system: system, user: user, image_url: image_url)
      else
        nil
      end
    rescue StandardError => e
      Rollbar.error(e) if defined?(Rollbar)
      nil
    end

    private

    def openai_chat(system:, user:, image_url:)
      user_content = image_url ? vision_user_content(user, image_url) : user
      response = self.class.post(
        OPENAI_URL,
        headers: {
          'Authorization' => "Bearer #{ENV.fetch('OPENAI_API_KEY')}",
          'Content-Type' => 'application/json'
        },
        body: {
          model: AiConfig::OPENAI_MODEL,
          response_format: { type: 'json_object' },
          messages: [
            { role: 'system', content: system },
            { role: 'user', content: user_content }
          ],
          temperature: 0.2
        }.to_json
      )
      return unless response.success?

      parse_json(response.dig('choices', 0, 'message', 'content'))
    end

    def anthropic_chat(system:, user:, image_url:)
      user_blocks = [{ type: 'text', text: user }]
      user_blocks << anthropic_image_block(image_url) if image_url.present?
      response = self.class.post(
        ANTHROPIC_URL,
        headers: {
          'x-api-key' => ENV.fetch('ANTHROPIC_API_KEY'),
          'anthropic-version' => '2023-06-01',
          'Content-Type' => 'application/json'
        },
        body: {
          model: AiConfig::ANTHROPIC_MODEL,
          max_tokens: 1024,
          system: system,
          messages: [{ role: 'user', content: user_blocks }],
          temperature: 0.2
        }.to_json
      )
      return unless response.success?

      text = Array(response['content']).filter_map { |block| block['text'] if block['type'] == 'text' }.join
      parse_json(text)
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
