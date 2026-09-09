# frozen_string_literal: true

module EbWiki
  module Views
    module Cases
      class History < EbWiki::View
        expose :this_case do |history_page:|
          history_page.fetch(:record)
        end

        expose :versions do |history_page:|
          history_page.fetch(:versions)
        end

        expose :authors do |history_page:|
          history_page.fetch(:authors, {})
        end
      end
    end
  end
end
