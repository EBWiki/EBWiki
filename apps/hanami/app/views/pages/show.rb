# frozen_string_literal: true

module EbWiki
  module Views
    module Pages
      class Show < EbWiki::View
        configure do |config|
          config.template = "pages/show"
        end

        expose :page do |page:|
          page
        end
      end
    end
  end
end
