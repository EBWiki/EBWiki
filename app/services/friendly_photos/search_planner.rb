# frozen_string_literal: true

module FriendlyPhotos
  # LLM search planner: name-first queries for Wikimedia/Openverse only.
  class SearchPlanner
    include Service

    SYSTEM_PROMPT = <<~PROMPT.squish
      You plan search queries for finding openly licensed, dignified portraits of
      a person on Wikimedia Commons and Openverse for an EBWiki police-violence
      case page. Return JSON with key "queries" (array of 4-8 unique strings).
      Prefer incident-specific queries first: "Killing of {name}" and
      "Shooting of {name}", then "{name} {city} {year}", then portrait/family/
      memorial variants. Use the case slug and city/year to disambiguate from
      historical homonyms (e.g. Sir Walter Scott the novelist vs Walter Scott
      killed in 2015). Do NOT invent faces, licenses, or URLs. Do NOT suggest
      mugshot, booking, jail, inmate, arrest, or news/social scrape terms.
    PROMPT

    Result = Struct.new(:queries, :ai_used, keyword_init: true)

    def initialize(client: AiClient.new)
      @client = client
    end

    def call(name:, city: nil, year: nil, slug: nil)
      return stub_plan(name, city, year, slug) if AiConfig.stubbed?
      return heuristic(name, city, year, slug) unless AiConfig.enabled?

      ai_plan = llm_plan(name, city, year, slug)
      return ai_plan if ai_plan

      raise AiError, 'Search planner did not return queries from the AI provider.'
    end

    private

    attr_reader :client

    def llm_plan(name, city, year, slug)
      payload = client.chat_json(system: SYSTEM_PROMPT, user: planner_user(name, city, year, slug))
      queries = extract_queries(payload)
      return if queries.empty?

      Result.new(
        queries: QueryPrioritizer.call(queries: queries.first(SearchLimits::MAX_QUERIES)),
        ai_used: true
      )
    end

    def planner_user(name, city, year, slug)
      <<~USER.squish
        Person: #{name}
        City: #{city.presence || 'unknown'}
        Year: #{year.presence || 'unknown'}
        Case slug: #{slug.presence || 'unknown'}
      USER
    end

    def extract_queries(payload)
      Array(payload&.fetch('queries', nil)).map { |query| query.to_s.strip }.compact_blank.uniq
    end

    def heuristic(name, city, year, slug)
      HeuristicPlanner.call(name: name, city: city, year: year, slug: slug)
    end

    def stub_plan(name, city, year, slug)
      base = HeuristicPlanner.call(name: name, city: city, year: year, slug: slug)
      Result.new(
        queries: QueryPrioritizer.call(queries: base.queries + ["#{name} memorial portrait"]),
        ai_used: true
      )
    end
  end
end
