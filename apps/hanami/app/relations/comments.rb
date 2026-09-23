# frozen_string_literal: true

module EbWiki
  module Relations
    class Comments < EbWiki::DB::Relation
      schema :comments, infer: true
    end
  end
end
