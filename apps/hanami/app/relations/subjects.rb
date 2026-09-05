# frozen_string_literal: true

module EbWiki
  module Relations
    class Subjects < EbWiki::DB::Relation
      schema :subjects, infer: true do
        attribute :id, Types::Integer
        primary_key :id
        associations do
          belongs_to :case
        end
      end
    end
  end
end
