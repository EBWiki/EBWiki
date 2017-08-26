CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => ENV['EBWIKI_AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key  => ENV['EBWIKI_AWS_SECRET_ACCESS_KEY']
      # :region                 => ENV['S3_REGION'] # Change this for different AWS region. Default is 'us-east-1'
  }
  config.fog_directory  = ENV['S3_BUCKET']
end