# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OnboardUser do
  let(:user) { create(:user) }

  it 'adds the user to Mailchimp and sends a welcome email' do
    mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    allow(AddUserToMailchimp).to receive(:call)
    allow(UserMailer).to receive(:welcome_email).with(user: user).and_return(mail)

    described_class.call(user)

    expect(AddUserToMailchimp).to have_received(:call).with(user)
    expect(UserMailer).to have_received(:welcome_email).with(user: user)
    expect(mail).to have_received(:deliver_now)
  end
end
