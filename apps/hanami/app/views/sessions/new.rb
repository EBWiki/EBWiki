# frozen_string_literal: true

module EbWiki
  module Views
    module Sessions
      class New < EbWiki::View
        expose :error, default: nil
      end
    end
  end
end
