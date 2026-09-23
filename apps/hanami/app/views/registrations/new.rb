# frozen_string_literal: true

module EbWiki
  module Views
    module Registrations
      class New < EbWiki::View
        expose :errors, default: []
        expose :values, default: {}
      end
    end
  end
end
