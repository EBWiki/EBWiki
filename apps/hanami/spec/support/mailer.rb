# frozen_string_literal: true

require "eb_wiki/mailer"

RSpec.configure do |config|
  config.before do
    EbWiki::Mailer.reset_deliveries!
  end
end
