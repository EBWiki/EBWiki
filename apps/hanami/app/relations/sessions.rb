# frozen_string_literal: true

module EbWiki
  module Relations
    class Sessions < EbWiki::DB::Relation
      schema :sessions, infer: true
    end
  end
end
