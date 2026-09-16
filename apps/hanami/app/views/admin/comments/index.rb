# frozen_string_literal: true

module EbWiki
  module Views
    module Admin
      module Comments
        class Index < EbWiki::View
          expose :comments
          expose :authors
          expose :case_slugs
        end
      end
    end
  end
end
