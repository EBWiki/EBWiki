# frozen_string_literal: true

describe UserPolicy do
  subject { described_class }
  let (:user) { FactoryBot.create(:user) }

  permissions :update? do
    it 'denies access if not current user doing the update' do
      expect(subject).not_to permit(FactoryBot.create(:user), User.new)
      expect(subject).not_to permit(FactoryBot.create(:user), user)
    end

    it 'permits access if  current user updating self account' do
      expect(subject).to permit(user, user)
    end
  end
end
