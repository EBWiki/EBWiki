# frozen_string_literal: true

module EbWiki
  module Relations
    class Links < EbWiki::DB::Relation
      schema :links, infer: true
    end
  end
end
