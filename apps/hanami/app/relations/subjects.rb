# frozen_string_literal: true

module EbWiki
  module Relations
    class Subjects < EbWiki::DB::Relation
      schema :subjects, infer: true do
        associations do
          belongs_to :case
        end
      end
    end
  end
end
