# frozen_string_literal: true

module EbWiki
  module Views
    module Organizations
      class Edit < EbWiki::View
        expose :organization
        expose :errors, default: []
        expose :values, default: {}
      end
    end
  end
end
