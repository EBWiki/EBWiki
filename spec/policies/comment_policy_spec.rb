# frozen_string_literal: true

require 'rails_helper'

describe CommentPolicy do
  subject { described_class }

  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }
  let(:comment) { FactoryBot.create(:comment) }

  permissions :destroy? do
    it 'denies access if the current user is not an admin' do
      expect(subject).not_to permit(user, comment)
    end

    it 'permits access if the current user is an admin' do
      expect(subject).to permit(admin, comment)
    end
  end
end
