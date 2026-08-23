# frozen_string_literal: true

module EbWiki
  module Views
    module Organizations
      class Show < EbWiki::View
        expose :organization do |organization:|
          organization
        end
      end
    end
  end
end
