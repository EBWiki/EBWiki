# frozen_string_literal: true

module EbWiki
  module Views
    module Users
      class Edit < EbWiki::View
        expose :profile
        expose :errors, default: []
        expose :values, default: {}
      end
    end
  end
end
