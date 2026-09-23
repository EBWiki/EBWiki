# frozen_string_literal: true

module EbWiki
  module Relations
    class States < EbWiki::DB::Relation
      schema :states, infer: true do
        attribute :id, Types::Integer
        primary_key :id
        associations do
          has_many :cases
        end
      end
    end
  end
end
