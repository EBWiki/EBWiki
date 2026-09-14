# frozen_string_literal: true

module EbWiki
  module Views
    module Sessions
      class Create < EbWiki::View
        config.template = "sessions/new"

        expose :error, default: nil
        expose :notice, default: nil
      end
    end
  end
end
