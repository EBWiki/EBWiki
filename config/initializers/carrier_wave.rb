# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.env.development?
    config.storage = :file
  else
    config.enable_processing = false if Rails.env.test?
  end
end
