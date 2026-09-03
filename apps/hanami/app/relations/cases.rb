# frozen_string_literal: true

module EbWiki
  module Relations
    class Cases < EbWiki::DB::Relation
      schema :cases, infer: true do
        # Generated tsvector is not inferred by ROM; search uses it when present.
        attribute :tsv, Types::String.optional
        associations do
          # `cases.state` is a leftover string column; the FK is state_id.
          belongs_to :us_state, foreign_key: :state_id, relation: :states
          has_many :subjects
          has_many :case_agencies
          has_many :agencies, through: :case_agencies
        end
      end

      use :pagination
      per_page 12
    end
  end
end
