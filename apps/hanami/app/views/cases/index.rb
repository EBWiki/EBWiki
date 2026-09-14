# frozen_string_literal: true

module EbWiki
  module Views
    module Cases
      class Index < EbWiki::View
        include Deps["repos.case_repo"]

        expose :cases do |page:|
          case_repo.homepage(page: page)
        end

        expose :total_cases do
          case_repo.total_count
        end

        expose :recently_updated_cases do
          case_repo.recently_updated
        end

        expose :page do |page:|
          [page.to_i, 1].max
        end

        expose :total_pages do |page:|
          count = case_repo.total_count
          pages = (count.to_f / EbWiki::Repos::CaseRepo::PAGE_SIZE).ceil
          [pages, 1].max
        end
      end
    end
  end
end
