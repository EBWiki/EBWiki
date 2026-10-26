# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable Metrics/BlockLength
RSpec.describe 'Case version revert authorization', type: :request, versioning: true do
  let(:regular_user) { create(:user) }
  let(:admin_user) { create(:user, admin: true) }
  let(:this_case) { create(:case, blurb: 'Original blurb') }

  def revert_path(case_record, version_id)
    "/cases/#{case_record.id}/versions/#{version_id}/revert"
  end

  before do
    this_case.update!(blurb: 'Updated blurb')
    @version_id = this_case.versions.last.id
  end

  describe 'POST /cases/:case_id/versions/:id/revert' do
    context 'when signed in as a non-admin' do
      before do
        sign_in regular_user
        post revert_path(this_case, @version_id), params: {}, headers: { 'HTTP_REFERER' => '/' }
      end

      it 'does not revert the case' do
        expect(this_case.reload.blurb).to eq('Updated blurb')
      end

      it 'redirects with an authorization alert' do
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when signed in as admin' do
      before do
        sign_in admin_user
        post revert_path(this_case, @version_id), params: {}, headers: { 'HTTP_REFERER' => '/' }
      end

      it 'reverts the case' do
        expect(this_case.reload.blurb).to eq('Original blurb')
      end

      it 'redirects to the case' do
        expect(response).to redirect_to(case_path(this_case))
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
