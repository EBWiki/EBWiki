# frozen_string_literal: true

require 'rails_helper'

describe Autobus, '#total_backup_size' do
  describe 'on success' do
    let(:mock_backups_result) {
      [
        {
         "id":"5a36241f9340510731fe3e61",
         "kind":"Daily",
         "created_at":"2017-12-17T08:00:31.841Z",
         "database":"HEROKU_POSTGRESQL_YELLOW_URL",
         "duration":27,
         "size":30000,
         "test_status":"Pass",
         "description":"",
         "url":"https://autobus-eu.s3.amazonaws.com/YELLOW_5a36241f9340510731fe3e61.dump?AWSAccessKeyId=AKIAJENCGZ6XMPKWLLQA\\u0026Expires=1513540087\\u0026Signature=VFTzq9aWZfoPgiWs6LJvtcHj%2FnA%3D"
        },
        {
         "id":"5a35e97d9340510731fe3cf9",
         "kind":"Daily",
         "created_at":"2017-12-17T03:50:21.586Z",
         "database":"DATABASE_URL",
         "duration":11,
         "size":50000,
         "test_status":"Pass",
         "description":"",
         "url":"https://autobus-eu.s3.amazonaws.com/DATABASE_5a35e97d9340510731fe3cf9.dump?AWSAccessKeyId=AKIAJENCGZ6XMPKWLLQA\\u0026Expires=1513540087\\u0026Signature=6UB33lXo4%2FGbioO%2FKepbR%2BuJur8%3D"
        }
      ]
    }

    let(:mock_backups_result_with_empty_size) {
      [
        {
         "id":"5a36241f9340510731fe3e61",
         "kind":"Daily",
         "created_at":"2017-12-17T08:00:31.841Z",
         "database":"HEROKU_POSTGRESQL_YELLOW_URL",
         "duration":27,
         "size":30000,
         "test_status":"Pass",
         "description":"",
         "url":"https://autobus-eu.s3.amazonaws.com/YELLOW_5a36241f9340510731fe3e61.dump?AWSAccessKeyId=AKIAJENCGZ6XMPKWLLQA\\u0026Expires=1513540087\\u0026Signature=VFTzq9aWZfoPgiWs6LJvtcHj%2FnA%3D"
        },
        {
         "id":"5a35e97d9340510731fe3cf9",
         "kind":"Daily",
         "created_at":"2017-12-17T03:50:21.586Z",
         "database":"DATABASE_URL",
         "duration":11,
         "size":50000,
         "test_status":"Pass",
         "description":"",
         "url":"https://autobus-eu.s3.amazonaws.com/DATABASE_5a35e97d9340510731fe3cf9.dump?AWSAccessKeyId=AKIAJENCGZ6XMPKWLLQA\\u0026Expires=1513540087\\u0026Signature=6UB33lXo4%2FGbioO%2FKepbR%2BuJur8%3D"
        },
        {
         "id":"5a36241f9340510731fe3e61",
         "kind":"Daily",
         "created_at":"2017-12-17T08:00:31.841Z",
         "database":"HEROKU_POSTGRESQL_YELLOW_URL",
         "duration":27,
         "size":nil,
         "test_status":"Pass",
         "description":"",
         "url":"https://autobus-eu.s3.amazonaws.com/YELLOW_5a36241f9340510731fe3e61.dump?AWSAccessKeyId=AKIAJENCGZ6XMPKWLLQA\\u0026Expires=1513540087\\u0026Signature=VFTzq9aWZfoPgiWs6LJvtcHj%2FnA%3D"
        },
      ]
    }
    it 'sends a successful total' do
      allow(mock_backups_result).to receive(:valid_encoding?) { true }
      allow(mock_backups_result).to receive(:strip) { mock_backups_result }
      allow(mock_backups_result).to receive(:encoding) { Encoding::UTF_8 }
      allow(mock_backups_result).to receive(:gsub) { mock_backups_result }
      stub_request(:get, ENV['AUTOBUS_SNAPSHOT_URL']).
         with(headers: {
           'Accept'=>'*/*',
           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
           'User-Agent'=>'Ruby',
         }).
         to_return(status: 200, body: mock_backups_result, headers: {})
      expect(subject.total_backup_size).to eq(80000)
    end

     it 'sends a successful total when entries have no size' do
      allow(mock_backups_result).to receive(:valid_encoding?) { true }
      allow(mock_backups_result).to receive(:strip) { mock_backups_result }
      allow(mock_backups_result).to receive(:encoding) { Encoding::UTF_8 }
      allow(mock_backups_result).to receive(:gsub) { mock_backups_result }
      stub_request(:get, ENV['AUTOBUS_SNAPSHOT_URL']).
         with(headers: {
           'Accept'=>'*/*',
           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
           'User-Agent'=>'Ruby',
         }).
         to_return(status: 200, body: mock_backups_result, headers: {})
      expect(subject.total_backup_size).to eq(80000)
    end
  end
end