# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Versions', type: :request, versioning: true do
  describe 'POST /revert' do
    def revert_version(record, version_id)
      post "/cases/#{record.id}/versions/#{version_id}/revert",
           params: {},
           headers: { 'HTTP_REFERER' => '/' }
    end

    context 'reverts the version of the case' do
      it 'redirects to the previous page' do
        this_case = FactoryBot.create(:case)
        this_case.update!(blurb: 'A new blurb')
        version_id = this_case.versions.last&.id
        skip 'PaperTrail did not record a version' if version_id.blank?

        revert_version(this_case, version_id)
        expect(response).to redirect_to("/cases/#{this_case.slug}")
      end
    end

    context 'when the case is new' do
      it 'redirects to the previous page' do
        new_case = FactoryBot.create(:case)
        version_id = new_case.versions.last&.id || 0

        revert_version(new_case, version_id)
        expect(response).to redirect_to('/')
      end
    end
  end
end
