require 'rails_helper'

feature 'External request' do
  it 'correctly calls MailChimp api' do

    # uri = URI("https://apikey:#{ENV['MAILCHIMP_API_KEY']}@us11.api.mailchimp.com/3.0/lists/#{ENV['MAILCHIMP_LIST_ID']}/members/b58996c504c5638798eb6b511e6f49af")

    # response = Net::HTTP.get(uri)

    # expect(response).to have_http_status(200)
  end

  	# let(:user) { create(:user) }

	# it "calls mailchimp correctly" do
 #    opts = {
 #      email: {email: user.email},
 #      id: ENV['MAILCHIMP_LIST_ID'],
 #      double_optin: true,
 #    }
 #    clazz = Rails.configuration.mailchimp.lists.class
 #    clazz.any_instance.should_receive(:subscribe).with(opts).once
 #    user.send(:add_to_mailchimp, true)
 #  end



  it "adds a user to the newsletter if the 'subscribed' box is checked" do

  end

  it "returns 'pending' for users who have subscribed on the EBW subscribe box but not email confirmation" do

  end

  it "returns 'pending' for users who have subscribed via the MC web form but not email confirmation" do

  end

  it "returns subscribed for users who have subscribed via the MailChimp web form and confirmed" do

  end

  it "unsubscribes the user from the newsletter if 'subscribed' box is unchecked" do

  end

  it "returns unsubscribed for users who have unchecked the EBW subscribe box" do

  end

  it "returns unsubscribed for users who have clicked the unsubscribed link in an email" do

  end
end
