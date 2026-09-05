# frozen_string_literal: true

module EbWiki
  module Relations
    class Follows < EbWiki::DB::Relation
      schema :follows, infer: true
    end
  end
end
