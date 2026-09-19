# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show.html.erb', type: :view do
  it 'displays an update button if the user is the current user' do
    user1 = FactoryBot.create(:user, last_sign_in_at: Time.now.utc)
    login_as(user1, scope: :user)
    # https://github.com/varvet/pundit/issues/339#issuecomment-237563113
    allow(view).to receive(:policy) do |_record|
      Pundit.policy(user1, user1)
    end

    assign(:user, user1)
    render

    expect(rendered).to match(/Edit profile/m)
  end

  it 'displays an update button if the user is the current user' do
    user1 = FactoryBot.create(:user, last_sign_in_at: Time.now.utc)
    user2 = FactoryBot.create(:user, last_sign_in_at: Time.now.utc)

    login_as(user1, scope: :user)
    # https://github.com/varvet/pundit/issues/339#issuecomment-237563113
    allow(view).to receive(:policy) do |_record|
      Pundit.policy(user1, user2)
    end

    assign(:user, user1)
    render

    expect(rendered).not_to match(/Edit profile/m)
  end
end
