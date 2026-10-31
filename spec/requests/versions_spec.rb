# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Versions', type: :request, versioning: true do
  describe 'POST /revert' do
    let(:user) { FactoryBot.create(:user) }
    let(:this_case) { FactoryBot.create(:case) }

    context 'when signed out' do
      before do
        this_case.update!(blurb: "A new blurb")
        version_id = this_case.versions.last&.id
        post "/cases/#{this_case.id}/versions/#{version_id}/revert",
             params: {},
             headers: {
               "HTTP_REFERER": '/'
             }
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'reverts the version of the case' do
      before do
        sign_in user
        this_case.update!(blurb: "A new blurb")
        version_id = this_case.versions.last&.id
        post "/cases/#{this_case.id}/versions/#{version_id}/revert",
             params: {},
             headers: {
               "HTTP_REFERER": '/'
             }
      end

      it 'redirects to the previous page' do
        expect(response).to redirect_to("/cases/#{this_case.slug}")
      end
    end

    context 'when the case is new' do
      let(:new_case) { FactoryBot.create(:case) }

      before do
        sign_in user
        # New case has no versions; use invalid id to simulate revert of create
        version_id = new_case.versions.last&.id || 0
        post "/cases/#{new_case.id}/versions/#{version_id}/revert",
             params: {},
             headers: {
               "HTTP_REFERER": '/'
             }
      end

      it 'redirects to the previous page' do
        expect(response).to redirect_to('/')
      end
    end
  end
end
