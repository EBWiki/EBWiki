# frozen_string_literal: true

describe 'users:confirm_all' do
  include_context 'rake'

  let!(:unconfirmed_users) do
    users = create_list(:user, 5)
    users.each { |u| u.update_column(:confirmed_at, nil) }
    users
  end

  it 'updates confirmed_at of unconfirmed users' do
    subject.invoke
    unconfirmed_users.each do |user|
      user.reload
      expect(user.confirmed_at).to be_present
      expect(user.confirmed_at).to be_within(1.minute).of(Time.current)
    end
  end
end
