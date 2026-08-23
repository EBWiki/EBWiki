# frozen_string_literal: true

module EbWiki
  module Views
    module Agencies
      class Show < EbWiki::View
        expose :agency do |agency_page:|
          agency_page.fetch(:record)
        end

        expose :state do |agency_page:|
          agency_page[:state]
        end

        expose :cases do |agency_page:|
          agency_page.fetch(:cases)
        end
      end
    end
  end
end
