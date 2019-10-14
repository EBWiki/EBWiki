# frozen_string_literal: true

require 'rails_helper'

describe SendAdminEmail do
  let(:user) { FactoryBot.create(:user) }
  let!(:admin) { FactoryBot.create(:admin) }
  
  before do
    user.update_attributes(admin: true)
  end

  it 'should send a new admin email when a new admin is added' do
    SendAdminEmail.call(user: user)
    mail = ActionMailer::Base.deliveries.last
    expect(mail[:subject].to_s).to eq 'A new admin has been added.'
  end
  
  it 'should send a removed admin email when a admin is removed' do
    user.update_attributes(admin: false)
    SendAdminEmail.call(user: user)
    mail = ActionMailer::Base.deliveries.last
    expect(mail[:subject].to_s).to eq "#{user.name} is no longer an admin."
  end
end
