# frozen_string_literal: true

describe AgencyPolicy do
  subject { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, admin: true) }

  permissions :destroy? do
    it 'denies the ability to destroy agency if current user is not admin' do
      expect(subject).not_to permit(user)
    end

    it 'permits the ability to destroy agency if current user is an admin' do
      expect(subject).to permit(admin)
    end
  end
end
