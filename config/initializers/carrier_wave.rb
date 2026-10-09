# frozen_string_literal: true

CarrierWave.configure do |config|
  use_file_storage =
    Rails.env.local? ||
    (Rails.env.staging? &&
      (ENV['AWS_ACCESS_KEY_ID'].blank? || ENV['AWS_SECRET_KEY_ID'].blank?))

  if use_file_storage
    config.storage = :file
    config.enable_processing = false if Rails.env.test?
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
