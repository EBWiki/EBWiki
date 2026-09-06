# frozen_string_literal: true

module FriendlyPhotos
  # LLM search planner: name-first queries for Wikimedia/Openverse only.
  class SearchPlanner
    include Service

    SYSTEM_PROMPT = <<~PROMPT.squish
      You plan search queries for finding openly licensed, dignified portraits of
      a person on Wikimedia Commons and Openverse. Return JSON with key "queries"
      (array of 4-8 unique strings). Start with the person's exact name, then add
      portrait/family/yearbook/memorial variants and "Killing of {name}" /
      "Shooting of {name}" when relevant. Include city or year when provided.
      Do NOT invent faces, licenses, or URLs. Do NOT suggest mugshot, booking,
      jail, inmate, arrest, or news/social scrape terms.
    PROMPT

    Result = Struct.new(:queries, :ai_used, keyword_init: true)

    def initialize(client: AiClient.new)
      @client = client
    end

    def call(name:, city: nil, year: nil)
      return stub_plan(name, city, year) if AiConfig.stubbed?
      return heuristic(name, city, year) unless AiConfig.enabled?

      ai_plan = llm_plan(name, city, year)
      return ai_plan if ai_plan

      heuristic(name, city, year)
    end

    private

    attr_reader :client

    def llm_plan(name, city, year)
      payload = client.chat_json(system: SYSTEM_PROMPT, user: planner_user(name, city, year))
      queries = extract_queries(payload)
      return if queries.empty?

      Result.new(queries: queries.first(8), ai_used: true)
    end

    def planner_user(name, city, year)
      <<~USER.squish
        Person: #{name}
        City: #{city.presence || 'unknown'}
        Year: #{year.presence || 'unknown'}
      USER
    end

    def extract_queries(payload)
      Array(payload&.fetch('queries', nil)).map { |query| query.to_s.strip }.compact_blank.uniq
    end

    def heuristic(name, city, year)
      HeuristicPlanner.call(name: name, city: city, year: year)
    end

    def stub_plan(name, city, year)
      base = HeuristicPlanner.call(name: name, city: city, year: year)
      Result.new(queries: base.queries + ["#{name} memorial portrait"], ai_used: true)
    end
  end
end
