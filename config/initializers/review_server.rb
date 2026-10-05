# frozen_string_literal: true

# Disposable PR preview hosts (Railway/Render/Fly). Not used in production EBWiki.
if ENV['REVIEW_SERVER'] == '1'
  Rails.application.config.hosts << /.+\.railway\.app/
  Rails.application.config.hosts << /.+\.up\.railway\.app/
  Rails.application.config.hosts << /.+\.onrender\.com/

  Rails.application.config.after_initialize do
    CarrierWave.configure do |config|
      config.storage = :file
    end
    Searchkick.disable_callbacks if defined?(Searchkick)
  end
end
