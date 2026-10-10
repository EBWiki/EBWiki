# frozen_string_literal: true

module EbWiki
  module Relations
    class Agencies < EbWiki::DB::Relation
      schema :agencies, infer: true do
        attribute :id, Types::Integer
        primary_key :id
        associations do
          has_many :case_agencies
          has_many :cases, through: :case_agencies
        end
      end
    end
  end
end
