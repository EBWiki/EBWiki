# frozen_string_literal: true

require 'rails_helper'

describe Autobus, '#total_backup_size' do
  describe 'on success' do
    let(:mock_backups_result) do
      requests = JSON.parse(IO.read("#{Rails.root}/spec/fixtures/autobus_request.json"))
      requests['mock_backups_result']
    end

    let(:mock_backups_result_with_empty_size) do
      requests = JSON.parse(IO.read("#{Rails.root}/spec/fixtures/autobus_request.json"))
      requests['mock_backups_result_with_empty_size']
    end

    let(:autobus_headers) do
      {
        'Accept': '*/*',
        'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent': 'Ruby'
      }
    end
    it 'sends a successful total' do
      allow(mock_backups_result).to receive(:valid_encoding?) { true }
      allow(mock_backups_result).to receive(:strip) { mock_backups_result }
      allow(mock_backups_result).to receive(:encoding) { Encoding::UTF_8 }
      allow(mock_backups_result).to receive(:gsub) { mock_backups_result }
      stub_request(:get, ENV['AUTOBUS_SNAPSHOT_URL'])
        .with(headers: autobus_headers)
        .to_return(status: 200, body: mock_backups_result, headers: {})
      expect(subject.total_backup_size).to eq(80_000)
    end

    it 'sends a successful total when entries have no size' do
      allow(mock_backups_result).to receive(:valid_encoding?) { true }
      allow(mock_backups_result).to receive(:strip) { mock_backups_result }
      allow(mock_backups_result).to receive(:encoding) { Encoding::UTF_8 }
      allow(mock_backups_result).to receive(:gsub) { mock_backups_result }
      stub_request(:get, ENV['AUTOBUS_SNAPSHOT_URL']).
        with(headers: autobus_headers).
        to_return(status: 200, body: mock_backups_result, headers: {})
      expect(subject.total_backup_size).to eq(80_000)
    end
  end
end
