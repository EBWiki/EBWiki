# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CloudStorage do
  def with_env(vars)
    originals = vars.keys.to_h { |key| [key, ENV.fetch(key, nil)] }
    vars.each do |key, value|
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
    yield
  ensure
    originals.each do |key, value|
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
  end

  let(:aws_env) do
    {
      'AWS_ACCESS_KEY_ID' => 'aws-key',
      'AWS_SECRET_KEY_ID' => 'aws-secret',
      'S3_BUCKET' => 'ebwiki-prod',
      'STORAGE_PROVIDER' => nil,
      'SKIP_STORAGE_PROBE' => 'true',
      'FALLBACK_S3_ACCESS_KEY_ID' => nil,
      'FALLBACK_S3_SECRET_ACCESS_KEY' => nil,
      'FALLBACK_S3_BUCKET' => nil,
      'FALLBACK_S3_ENDPOINT' => nil
    }
  end

  let(:fallback_env) do
    {
      'AWS_ACCESS_KEY_ID' => nil,
      'AWS_SECRET_KEY_ID' => nil,
      'S3_BUCKET' => nil,
      'STORAGE_PROVIDER' => nil,
      'SKIP_STORAGE_PROBE' => 'true',
      'FALLBACK_S3_ACCESS_KEY_ID' => 'fallback-key',
      'FALLBACK_S3_SECRET_ACCESS_KEY' => 'fallback-secret',
      'FALLBACK_S3_BUCKET' => 'ebwiki-media',
      'FALLBACK_S3_ENDPOINT' => 'https://storage.railway.app',
      'FALLBACK_S3_REGION' => 'auto'
    }
  end

  let(:both_env) { aws_env.merge(fallback_env.except('AWS_ACCESS_KEY_ID', 'AWS_SECRET_KEY_ID', 'S3_BUCKET')) }

  before { described_class.reset! }
  after { described_class.reset! }

  describe '.active_provider' do
    it 'uses AWS when it is configured and reachable' do
      with_env(both_env) do
        expect(described_class.active_provider).to eq(described_class::AWS)
      end
    end

    it 'uses the fallback provider when AWS is down' do
      with_env(both_env.merge('SKIP_STORAGE_PROBE' => nil)) do
        allow(described_class).to receive(:ping_aws).and_return(false)
        expect(described_class.active_provider).to eq(described_class::FALLBACK)
      end
    end

    it 'uses the fallback provider when AWS is not configured' do
      with_env(fallback_env) do
        expect(described_class.active_provider).to eq(described_class::FALLBACK)
      end
    end

    it 'honors STORAGE_PROVIDER=fallback even when AWS is up' do
      with_env(both_env.merge('STORAGE_PROVIDER' => 'fallback')) do
        expect(described_class.active_provider).to eq(described_class::FALLBACK)
      end
    end

    it 'is nil when no cloud provider is configured' do
      with_env(
        'AWS_ACCESS_KEY_ID' => nil,
        'AWS_SECRET_KEY_ID' => nil,
        'S3_BUCKET' => nil,
        'STORAGE_PROVIDER' => nil,
        'FALLBACK_S3_ACCESS_KEY_ID' => nil,
        'FALLBACK_S3_SECRET_ACCESS_KEY' => nil,
        'FALLBACK_S3_BUCKET' => nil,
        'FALLBACK_S3_ENDPOINT' => nil
      ) do
        expect(described_class.active_provider).to be_nil
      end
    end
  end

  describe '.configure_carrierwave' do
    it 'points CarrierWave at AWS S3' do
      config = double('carrierwave-config')
      allow(config).to receive(:storage=)
      allow(config).to receive(:fog_credentials=)
      allow(config).to receive(:fog_directory=)
      allow(config).to receive(:fog_public=)

      with_env(aws_env) do
        described_class.configure_carrierwave(config)
      end

      expect(config).to have_received(:storage=).with(:fog)
      expect(config).to have_received(:fog_directory=).with('ebwiki-prod')
      expect(config).to have_received(:fog_public=).with(true)
    end

    it 'points CarrierWave at the S3-compatible fallback' do
      config = double('carrierwave-config')
      allow(config).to receive(:storage=)
      allow(config).to receive(:fog_credentials=)
      allow(config).to receive(:fog_directory=)
      allow(config).to receive(:fog_public=)

      with_env(fallback_env) do
        described_class.configure_carrierwave(config)
      end

      expect(config).to have_received(:storage=).with(:fog)
      expect(config).to have_received(:fog_directory=).with('ebwiki-media')
      expect(config).to have_received(:fog_public=).with(false)
      expect(config).to have_received(:fog_credentials=).with(
        hash_including(
          endpoint: 'https://storage.railway.app',
          path_style: true
        )
      )
    end

    it 'uses local files when no cloud provider is configured' do
      config = double('carrierwave-config')
      allow(config).to receive(:storage=)

      with_env(
        'AWS_ACCESS_KEY_ID' => nil,
        'AWS_SECRET_KEY_ID' => nil,
        'S3_BUCKET' => nil,
        'FALLBACK_S3_ACCESS_KEY_ID' => nil,
        'FALLBACK_S3_SECRET_ACCESS_KEY' => nil,
        'FALLBACK_S3_BUCKET' => nil,
        'FALLBACK_S3_ENDPOINT' => nil,
        'STORAGE_PROVIDER' => nil
      ) do
        described_class.configure_carrierwave(config)
      end

      expect(config).to have_received(:storage=).with(:file)
    end
  end

  describe '.switch_to_fallback' do
    it 'switches to the fallback after an AWS transport error' do
      config = double('carrierwave-config')
      allow(config).to receive(:storage=)
      allow(config).to receive(:fog_credentials=)
      allow(config).to receive(:fog_directory=)
      allow(config).to receive(:fog_public=)
      carrier_wave = Class.new
      carrier_wave.define_singleton_method(:configure) { |&block| block.call(config) }
      stub_const('CarrierWave', carrier_wave)

      with_env(both_env) do
        expect(described_class.active_provider).to eq(described_class::AWS)
        switched = described_class.switch_to_fallback(Timeout::Error.new)
        expect(switched).to eq(described_class::FALLBACK)
        expect(described_class.active_provider).to eq(described_class::FALLBACK)
      end
    end

    it 'does not switch on unrelated errors' do
      with_env(both_env) do
        switched = described_class.switch_to_fallback(ArgumentError.new('bad file'))
        expect(switched).to be_nil
        expect(described_class.active_provider).to eq(described_class::AWS)
      end
    end
  end
end
