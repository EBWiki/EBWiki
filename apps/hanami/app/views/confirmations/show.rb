# frozen_string_literal: true

module EbWiki
  module Views
    module Confirmations
      class Show < EbWiki::View
        expose :error, default: nil
      end
    end
  end
end
