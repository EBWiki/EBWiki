# frozen_string_literal: true

module EbWiki
  module Views
    module Admin
      module Users
        class Index < EbWiki::View
          expose :query do |query:|
            query
          end

          expose :users do |users:|
            users
          end
        end
      end
    end
  end
end
