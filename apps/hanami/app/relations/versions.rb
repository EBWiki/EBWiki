# frozen_string_literal: true

module EbWiki
  module Relations
    class Versions < EbWiki::DB::Relation
      schema :versions, infer: true
    end
  end
end
