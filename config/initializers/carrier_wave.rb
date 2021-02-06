# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.env.development?
    config.storage = :file
  else
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_KEY_ID']
      # region: ENV['S3_REGION'] # Change this for different AWS region. Default is 'us-east-1'
    }
    config.storage = :fog
    config.fog_directory = ENV['S3_BUCKET']

    if Rails.env.test?
      config.enable_processing = false
    end
end
