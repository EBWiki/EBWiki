# frozen_string_literal: true

module EbWiki
  module Views
    module Cases
      class Edit < EbWiki::View
        include Deps["repos.agency_repo"]

        expose :this_case do |case_page:|
          case_page.fetch(:record)
        end
        expose :subjects do |case_page:|
          case_page.fetch(:subjects)
        end
        expose :links do |case_page:|
          case_page.fetch(:links)
        end
        expose :selected_agency_ids do |case_page:|
          case_page.fetch(:agencies).map(&:id)
        end
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
