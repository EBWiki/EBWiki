# frozen_string_literal: true

class CloudStorage
  class Settings
    def self.for(provider)
      case provider
      when AWS then aws
      when FALLBACK then fallback
      when nil then nil
      else
        raise ArgumentError, "unknown storage provider: #{provider}"
      end
    end

    def self.aws
      {
        public: true,
        directory: ENV.fetch('S3_BUCKET', nil),
        fog: fog_aws
      }
    end

    def self.fallback
      {
        public: false,
        directory: ENV.fetch('FALLBACK_S3_BUCKET', nil),
        fog: fog_fallback
      }
    end

    def self.fog_aws
      {
        provider: 'AWS',
        aws_access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
        aws_secret_access_key: ENV.fetch('AWS_SECRET_KEY_ID', nil),
        region: ENV.fetch('S3_REGION', 'us-east-1')
      }
    end
    private_class_method :fog_aws

    def self.fog_fallback
      {
        provider: 'AWS',
        aws_access_key_id: ENV.fetch('FALLBACK_S3_ACCESS_KEY_ID', nil),
        aws_secret_access_key: ENV.fetch('FALLBACK_S3_SECRET_ACCESS_KEY', nil),
        region: ENV.fetch('FALLBACK_S3_REGION', 'auto'),
        endpoint: ENV.fetch('FALLBACK_S3_ENDPOINT', nil),
        path_style: true
      }
    end
    private_class_method :fog_fallback
  end
end
