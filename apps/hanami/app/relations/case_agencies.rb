# frozen_string_literal: true

module EbWiki
  module Relations
    class CaseAgencies < EbWiki::DB::Relation
      schema :case_agencies, infer: true do
        attribute :id, Types::Integer
        primary_key :id
        associations do
          belongs_to :case
          belongs_to :agency
        end
      end
    end
  end
end
