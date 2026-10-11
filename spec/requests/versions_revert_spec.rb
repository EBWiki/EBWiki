# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Versions revert', type: :request, versioning: true do
  def revert_path(case_record, version_id)
    "/cases/#{case_record.id}/versions/#{version_id}/revert"
  end

  describe 'POST /cases/:case_id/versions/:id/revert' do
    let(:user) { create(:user) }
    let(:this_case) { create(:case, blurb: 'Original blurb') }

    context 'when signed out' do
      before do
        this_case.update!(blurb: 'Updated blurb')
        version_id = this_case.versions.last.id
        post revert_path(this_case, version_id), params: {}, headers: { 'HTTP_REFERER' => '/' }
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not change the case' do
        expect(this_case.reload.blurb).to eq('Updated blurb')
      end
    end

    context 'when signed in' do
      before { sign_in user }

      context 'reverting an update version' do
        before do
          this_case.update!(blurb: 'Updated blurb')
          version_id = this_case.versions.last.id
          post revert_path(this_case, version_id), params: {}, headers: { 'HTTP_REFERER' => '/' }
        end

        it 'redirects to the case' do
          expect(response).to redirect_to(case_path(this_case))
        end

        it 'restores the previous attribute value' do
          expect(this_case.reload.blurb).to eq('Original blurb')
        end
      end

      context 'when the version belongs to another case' do
        let(:other_case) { create(:case, blurb: 'Other original') }

        before do
          other_case.update!(blurb: 'Other updated')
          foreign_version_id = other_case.versions.last.id
          post revert_path(this_case, foreign_version_id),
               params: {},
               headers: { 'HTTP_REFERER' => '/' }
        end

        it 'responds with a redirect and alert without changing this case' do
          expect(response).to have_http_status(:redirect)
          expect(flash[:alert]).to be_present
          expect(this_case.reload.blurb).to eq('Original blurb')
        end
      end

      context 'when reverting a create version' do
        let(:new_case) { create(:case) }

        before do
          create_version = new_case.versions.find_by!(event: 'create')
          post revert_path(new_case, create_version.id),
               params: {},
               headers: { 'HTTP_REFERER' => '/' }
        end

        it 'does not destroy the case' do
          expect(Case.exists?(new_case.id)).to be true
        end

        it 'shows an alert' do
          expect(flash[:alert]).to be_present
        end
      end

      context 'when the version id does not exist for the case' do
        before do
          post revert_path(this_case, 0), params: {}, headers: { 'HTTP_REFERER' => '/' }
        end

        it 'does not destroy the case' do
          expect(Case.exists?(this_case.id)).to be true
        end

        it 'shows an alert' do
          expect(flash[:alert]).to be_present
        end
      end
    end
  end
end
