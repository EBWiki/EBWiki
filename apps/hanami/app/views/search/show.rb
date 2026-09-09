# frozen_string_literal: true

module EbWiki
  module Views
    module Search
      class Show < EbWiki::View
        include Deps["repos.case_repo"]

        expose :query do |query:|
          query
        end

        expose :cases do |query:, page:, state_id:|
          case_repo.search(query: query, page: page, state_id: state_id)
        end

        expose :total do |query:, state_id:|
          case_repo.search_count(query: query, state_id: state_id)
        end
      end
    end
  end
end
