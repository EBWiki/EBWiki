# frozen_string_literal: true

module EbWiki
  module Relations
    class Organizations < EbWiki::DB::Relation
      schema :organizations, infer: true
    end
  end
end
