# frozen_string_literal: true

module EbWiki
  module Views
    module Users
      class Show < EbWiki::View
        expose :profile
        expose :followed_cases
      end
    end
  end
end
