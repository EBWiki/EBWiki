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

    Result = Struct.new(:likely_mugshot, :reasons, :score, :ai_used, keyword_init: true)

    def initialize(client: AiClient.new)
      @client = client
    end

    def call(hit:)
      return stub_result(hit) if AiConfig.stubbed?
      return skip unless AiConfig.enabled?

      ai_result = llm_result(hit)
      ai_result || skip
    end

    private

    attr_reader :client

    def llm_result(hit)
      user = <<~USER.squish
        Title: #{hit.title}
        Description: #{hit.description}
        Source: #{hit.source}
        Page: #{hit.page_url}
        Classify the image at the provided URL.
      USER
      payload = client.chat_json(system: SYSTEM_PROMPT, user: user, image_url: hit.image_url)
      return unless payload

      Result.new(
        likely_mugshot: ActiveModel::Type::Boolean.new.cast(payload['likely_mugshot']),
        reasons: Array(payload['reasons']).map(&:to_s).reject(&:blank?),
        score: payload['score'].to_i,
        ai_used: true
      )
    end

    def stub_result(hit)
      text = [hit.title, hit.description].compact.join(' ')
      heuristic = MugshotClassifier.call(text: text)
      Result.new(
        likely_mugshot: heuristic.likely_mugshot,
        reasons: heuristic.reasons + ['stub vision'],
        score: heuristic.score + 1,
        ai_used: true
      )
    end

    def skip
      Result.new(likely_mugshot: false, reasons: [], score: 0, ai_used: false)
    end
  end
end
