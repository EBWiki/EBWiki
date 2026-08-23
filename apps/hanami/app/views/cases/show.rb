# frozen_string_literal: true

module EbWiki
  module Views
    module Cases
      class Show < EbWiki::View
        expose :this_case do |case_page:|
          case_page.fetch(:record)
        end

        expose :state do |case_page:|
          case_page[:state]
        end

        expose :subjects do |case_page:|
          case_page.fetch(:subjects)
        end

        expose :agencies do |case_page:|
          case_page.fetch(:agencies)
        end

        expose :links do |case_page:|
          case_page.fetch(:links)
        end
      end
    end
  end
end
