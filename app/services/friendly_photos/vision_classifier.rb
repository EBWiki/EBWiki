# frozen_string_literal: true

module FriendlyPhotos
  # Vision model scores a candidate image as friendly portrait vs mugshot/booking.
  class VisionClassifier
    include Service

    SYSTEM_PROMPT = <<~PROMPT.squish
      You classify a single image for EBWiki case pages. Return JSON with:
      "likely_mugshot" (boolean), "score" (integer, higher = more dignified portrait),
      and "reasons" (array of short strings). Mark likely_mugshot true for booking
      photos, jail ID photos, height charts, or police mugshots. Mark false for
      family photos, yearbook portraits, memorial photos, and dignified headshots.
      Downrank protest/incident stills with a lower score but do not mark them
      mugshots unless they are clearly booking photos.
    PROMPT

    Result = Struct.new(:likely_mugshot, :reasons, :score, :ai_used, :failed, keyword_init: true)

    def initialize(client: AiClient.new)
      @client = client
    end

    def self.skipped_result
      Result.new(likely_mugshot: false, reasons: [], score: 0, ai_used: false, failed: false)
    end

    def call(hit:)
      return stub_result(hit) if AiConfig.stubbed?
      return self.class.skipped_result unless AiConfig.enabled?

      ai_result = llm_result(hit)
      return ai_result if ai_result

      handle_failure(hit)
    end

    private

    attr_reader :client

    def llm_result(hit)
      payload = client.chat_json(
        system: SYSTEM_PROMPT,
        user: vision_user(hit),
        image_url: hit.image_url
      )
      result_from_payload(payload)
    end

    def vision_user(hit)
      <<~USER.squish
        Title: #{hit.title}
        Description: #{hit.description}
        Source: #{hit.source}
        Page: #{hit.page_url}
        Classify the image at the provided URL.
      USER
    end

    def result_from_payload(payload)
      return unless payload

      Result.new(
        likely_mugshot: ActiveModel::Type::Boolean.new.cast(payload['likely_mugshot']),
        reasons: Array(payload['reasons']).map(&:to_s).compact_blank,
        score: payload['score'].to_i,
        ai_used: true,
        failed: false
      )
    end

    def handle_failure(hit)
      log_failure(hit)
      if AiConfig.require_ai?
        Result.new(
          likely_mugshot: false,
          reasons: ['vision API failed — cannot verify'],
          score: -50,
          ai_used: false,
          failed: true
        )
      else
        raise AiError, 'Vision classifier did not score this image.'
      end
    end

    def log_failure(hit)
      Rails.logger.warn(
        "[FriendlyPhotos::VisionClassifier] failed for #{hit.image_url} " \
        "(title=#{hit.title.inspect})"
      )
    end

    def stub_result(hit)
      text = [hit.title, hit.description].compact.join(' ')
      heuristic = MugshotClassifier.call(text: text)
      Result.new(
        likely_mugshot: heuristic.likely_mugshot,
        reasons: heuristic.reasons + ['stub vision'],
        score: heuristic.score + 1,
        ai_used: true,
        failed: false
      )
    end
  end
end
