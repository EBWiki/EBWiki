# frozen_string_literal: true

module EbWiki
  module Relations
    class Users < EbWiki::DB::Relation
      schema :users, infer: true
    end
  end
end
