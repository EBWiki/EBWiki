# frozen_string_literal: true

module EbWiki
  module Views
    module Cases
      class Followers < EbWiki::View
        expose :this_case do |followers_page:|
          followers_page.fetch(:record)
        end

        expose :followers do |followers_page:|
          followers_page.fetch(:followers)
        end
      end
    end
  end
end
