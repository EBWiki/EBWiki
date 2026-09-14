# frozen_string_literal: true

module EbWiki
  module Views
    module Organizations
      class Index < EbWiki::View
        include Deps["repos.organization_repo"]

        expose :organizations do
          organization_repo.all_ordered
        end
      end
    end
  end
end
