# frozen_string_literal: true

module EbWiki
  module Views
    module Cases
      class New < EbWiki::View
        include Deps["repos.agency_repo"]

        expose :errors, default: []
        expose :values, default: {}
        expose :agencies do
          agency_repo.all_ordered
        end
        expose :states do
          Hanami.app["relations.states"].order(Hanami.app["relations.states"][:name].asc).to_a
        end
      end
    end
  end
end
