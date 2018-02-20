# frozen_string_literal: true

CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: 'AKIAJ26WBHAI25LIOH6A',
    aws_secret_access_key: '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'
    # region: ENV['S3_REGION'] # Change this for different AWS region. Default is 'us-east-1'
  }
  config.fog_directory = ENV['S3_BUCKET']
end
