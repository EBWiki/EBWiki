# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Versions', type: :request, versioning: true do
  describe 'POST /revert' do
    context 'reverts the version of the case' do
      let(:this_case) { FactoryBot.create(:case) }

      before do
        this_case.update!(blurb: 'A new blurb')
        version = this_case.versions.last
        expect(version).to be_present

        post "/cases/#{this_case.id}/versions/#{version.id}/revert",
             params: {},
             headers: {
               'HTTP_REFERER': '/'
             }
      end

      it 'redirects to the previous page' do
        expect(response).to redirect_to("/cases/#{this_case.slug}")
      end
    end

    context 'when the case is new' do
      let(:new_case) { FactoryBot.create(:case) }

      before do
        # New case has no update versions; use invalid id to simulate revert of create
        version_id = new_case.versions.last&.id || 0
        post "/cases/#{new_case.id}/versions/#{version_id}/revert",
             params: {},
             headers: {
               'HTTP_REFERER': '/'
             }
      end

      it 'redirects to the previous page' do
        expect(response).to redirect_to('/')
      end
    end
  end
end
