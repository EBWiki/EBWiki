# frozen_string_literal: true

module EbWiki
  module Views
    module Sessions
      class New < EbWiki::View
        expose :error, default: nil
        expose :notice, default: nil
      end
    end
  end
end
