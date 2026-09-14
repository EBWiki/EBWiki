# frozen_string_literal: true

require "json"

module EbWiki
  module Views
    module Maps
      class Index < EbWiki::View
        include Deps["repos.case_repo"]

        expose :locations do
          case_repo.map_locations
        end

        expose :locations_json do
          JSON.generate(case_repo.map_locations)
        end
      end
    end
  end
end
