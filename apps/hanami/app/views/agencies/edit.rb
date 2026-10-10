# frozen_string_literal: true

module EbWiki
  module Views
    module Agencies
      class Edit < EbWiki::View
        expose :agency
        expose :errors, default: []
        expose :values, default: {}
        expose :states do
          Hanami.app["relations.states"].order(Hanami.app["relations.states"][:name].asc).to_a
        end
      end
    end
  end
end
