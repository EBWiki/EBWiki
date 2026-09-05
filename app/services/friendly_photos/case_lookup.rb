# frozen_string_literal: true

module FriendlyPhotos
  # Operator search across case id, slug, name, city, and date.
  class CaseLookup
    include Service

    def call(filter:, query: nil, location: nil, date: nil, case_id: nil)
      scope = filtered_scope(filter)
      scope = apply_case_id(scope, case_id)
      scope = apply_query(scope, query)
      scope = apply_location(scope, location)
      apply_date(scope, date)
    end

    private

    def filtered_scope(filter)
      case filter
      when 'mugshot' then Case.mugshot
      when 'missing' then Case.where(avatar: [nil, ''])
      when 'unclassified' then Case.unclassified
      when 'portrait' then Case.portrait
      else Case.needing_friendly_photo
      end
    end

    def apply_case_id(scope, case_id)
      return scope if case_id.blank?

      token = case_id.to_s.strip
      return scope.where(id: token) if token.match?(/\A\d+\z/)

      scope.where(slug: token)
    end

    def apply_query(scope, query)
      return scope if query.blank?

      pattern = "%#{Case.sanitize_sql_like(query.strip)}%"
      scope.left_joins(:subjects).where(
        'subjects.name ILIKE :q OR cases.title ILIKE :q OR cases.slug ILIKE :q',
        q: pattern
      ).distinct
    end

    def apply_location(scope, location)
      return scope if location.blank?

      pattern = "%#{Case.sanitize_sql_like(location.strip)}%"
      scope.left_joins(:state).where(
        'cases.city ILIKE :q OR states.name ILIKE :q OR states.ansi_code ILIKE :q',
        q: pattern
      ).distinct
    end

    def apply_date(scope, date)
      parsed = parse_date(date)
      return scope unless parsed

      scope.where(date: parsed)
    end

    def parse_date(value)
      return if value.blank?

      Date.iso8601(value.to_s)
    rescue ArgumentError
      nil
    end
  end
end
