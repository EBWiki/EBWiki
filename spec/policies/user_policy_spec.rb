# frozen_string_literal: true

describe UserPolicy do
  subject { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, admin: true) }

  permissions :edit? do
    it 'denies access current user is not user or admin' do
      expect(subject).not_to permit(user, admin)
    end

    it 'permits access if user is editing own account' do
      expect(subject).to permit(user, user)
    end

    it 'permits access if user is an admin' do
      expect(subject).to permit(admin, user)
    end
  end

  permissions :update? do
    it 'denies access if not current user doing the update' do
      expect(subject).not_to permit(FactoryBot.create(:user), user)
    end

    it 'permits access if user is updating own account' do
      expect(subject).to permit(user, user)
    end

    it 'permits access if current user is an admin' do
      expect(subject).to permit(admin, user)
    end
  end
end
