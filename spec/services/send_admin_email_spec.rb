# frozen_string_literal: true

require 'rails_helper'

describe SendAdminEmail do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }

  it 'should send a new admin email when a new admin is added' do
    admin
    user.update_attributes({ admin: true })
    SendAdminEmail.call(user: user)
    mail = ActionMailer::Base.deliveries.last
    expect(mail[:subject].to_s).to eq 'A new admin has been added.'
  end
end