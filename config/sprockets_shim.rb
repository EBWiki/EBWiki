# frozen_string_literal: true

# bootstrap-sass checks Sprockets::Rails::VERSION at boot; Propshaft does not ship Sprockets.
module Sprockets
  module Rails
    VERSION = '3.7.0'

    module Helper
      AssetNotFound = Class.new(StandardError)
    end
  end
end
