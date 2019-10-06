# frozen_string_literal: true

describe 'users:confirm_all' do
  include_context 'rake'

  let!(:users) { create_list(:user, 5, confirmed_at: (Time.now - 1.day)) }

  it 'updates confirmed_at of users' do
    subject.invoke
    User.all.each do |user|
      expect(user.confirmed_at.day).to eq Time.now.day
    end
  end
end
