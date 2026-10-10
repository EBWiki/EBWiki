# frozen_string_literal: true

module EbWiki
  module Views
    module FriendlyPhotos
      class Index < EbWiki::View
        include Deps["repos.case_repo"]

        expose :cases do |page:|
          case_repo.photo_review_cases(page: page)
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
