# frozen_string_literal: true

module EbWiki
  module Views
    module Organizations
      class New < EbWiki::View
        expose :errors, default: []
        expose :values, default: {}
        expose :organization, default: nil
      end
    end
  end
end
