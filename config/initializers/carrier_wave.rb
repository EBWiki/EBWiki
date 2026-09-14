# frozen_string_literal: true

require_relative '../../app/services/cloud_storage'

CarrierWave.configure do |config|
  if Rails.env.development?
    config.storage = :file
  elsif Rails.env.test?
    config.storage = :file
    config.enable_processing = false
  else
    CloudStorage.configure_carrierwave(config)
  end
end
