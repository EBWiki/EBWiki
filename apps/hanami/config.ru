# frozen_string_literal: true

require "hanami/boot"
use Rack::MethodOverride

run Hanami.app
