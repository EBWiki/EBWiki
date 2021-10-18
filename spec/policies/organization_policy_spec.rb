# frozen_string_literal: true

describe OrganizationPolicy do
  subject { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, admin: true) }

  permissions :edit? do
    it 'denies access current user is not admin' do
      expect(subject).not_to permit(user)
    end

    it 'permits access if user is an admin' do
      expect(subject).to permit(admin)
    end
  end

  permissions :update? do
    it 'denies access current user is not admin' do
      expect(subject).not_to permit( user)
    end

    it 'permits access if user is an admin' do
      expect(subject).to permit(admin)
    end
  end
end
