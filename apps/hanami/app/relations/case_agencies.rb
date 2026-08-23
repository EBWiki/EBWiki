# frozen_string_literal: true

module EbWiki
  module Relations
    class CaseAgencies < EbWiki::DB::Relation
      schema :case_agencies, infer: true do
        associations do
          belongs_to :case
          belongs_to :agency
        end
      end
    end
  end
end
