# frozen_string_literal: true

require "hanami/boot"
require_relative "lib/eb_wiki/staging_basic_auth"

use EbWiki::StagingBasicAuth
use Rack::MethodOverride

run Hanami.app
