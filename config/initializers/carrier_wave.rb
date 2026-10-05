# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.env.development?
    config.storage = :file
  elsif Rails.env.test?
    config.storage = :file
    config.enable_processing = false
  elsif Rails.env.staging? &&
        (ENV['AWS_ACCESS_KEY_ID'].blank? || ENV['AWS_SECRET_KEY_ID'].blank?)
    config.storage = :file
  else
    config.storage = :fog
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
      aws_secret_access_key: ENV.fetch('AWS_SECRET_KEY_ID', nil)
    }
    config.fog_directory = ENV.fetch('S3_BUCKET', nil)
  end
end
