# frozen_string_literal: true

require 'rails_helper'
require 'open3'

RSpec.describe 'config/environments/staging.rb' do
  specify 'registers StagingBasicAuth on the middleware stack when loaded' do
    checker = Rails.root.join('script/check_staging_basic_auth_middleware.rb')
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, checker.to_s, chdir: Rails.root.to_s)

    expect(status).to be_success, [stdout, stderr].join
  end
end
