# frozen_string_literal: true

module EbWiki
  module Views
    module Agencies
      class Index < EbWiki::View
        include Deps["repos.agency_repo"]

        expose :agencies do
          agency_repo.all_ordered
        end
      end
    end
  end
end
