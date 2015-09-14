require 'rails_helper'

	describe "#subscribe_to_mailchimp" do
	  let(:user) { create(:user) }
	  it "calls mailchimp correctly" do
	    opts = {
	      email: {email: user.email},
	      id: ENV['MAILCHIMP_LIST_ID'],
	      double_optin: false,
	    }
	    clazz = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY']).lists.class
	    clazz.any_instance.should_receive(:subscribe).with(opts).once
	    user.send(:add_to_mailchimp, true)
	  end

	  # it "calls mailchimp with a pending subscriber" do
	  #   opts = {
	  #     email: {email: user.email},
	  #     id: ENV['MAILCHIMP_LIST_ID'],
	  #     double_optin: false,
	  #   }
	  #   clazz = Rails.configuration.mailchimp.lists.class
	  #   clazz.any_instance.should_receive(:subscribe).with(opts).once
	  #   user.send(:add_to_mailchimp, true)
	  # end

	  # it "calls mailchimp with " do
	  #   opts = {
	  #     email: {email: user.email},
	  #     id: ENV['MAILCHIMP_LIST_ID'],
	  #     double_optin: false,
	  #   }
	  #   clazz = Rails.configuration.mailchimp.lists.class
	  #   clazz.any_instance.should_receive(:subscribe).with(opts).once
	  #   user.send(:add_to_mailchimp, true)
	  # end
	end