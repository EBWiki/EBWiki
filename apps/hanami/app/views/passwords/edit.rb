# frozen_string_literal: true

module EbWiki
  module Views
    module Passwords
      class Edit < EbWiki::View
        expose :token
        expose :error, default: nil
      end
    end
  end
end
