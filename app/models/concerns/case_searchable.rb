# frozen_string_literal: true

# Wires up Postgres full-text search for the Case model via pg_search,
# backed by the generated `tsv` tsvector column added in
# 20260428201731_add_tsv_to_cases.
module CaseSearchable
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model

    pg_search_scope :search_text,
                    against: %i[title blurb overview city summary],
                    using: {
                      tsearch: {
                        dictionary: 'english',
                        tsvector_column: 'tsv',
                        prefix: true
                      }
                    }
  end
end
