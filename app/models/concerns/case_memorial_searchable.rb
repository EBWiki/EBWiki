# frozen_string_literal: true

# Postgres full-text (tsvector) and trigram search for the memorial photo grid.
module CaseMemorialSearchable
  extend ActiveSupport::Concern

  included do
    pg_search_scope :memorial_text_search,
                    against: %i[title blurb overview city],
                    using: {
                      tsearch: {
                        dictionary: 'english',
                        tsvector_column: 'tsv',
                        prefix: true
                      },
                      trigram: {
                        word_similarity: true,
                        threshold: 0.3
                      }
                    }

    pg_search_scope :memorial_name_trgm,
                    against: :title,
                    using: {
                      trigram: { threshold: 0.2 }
                    }

    scope :memorial_photo_indexable, lambda {
      where('cases.photo_status IS NOT NULL OR cases.photo_url IS NOT NULL')
    }
  end
end
