# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Versions', type: :request, versioning: true do
  describe 'POST /revert' do
    def post_revert(record, version_id)
      post "/cases/#{record.id}/versions/#{version_id}/revert",
           params: {},
           headers: {
             'HTTP_REFERER' => '/'
           }
    end

    context 'when the case has a version' do
      let(:this_case) { FactoryBot.create(:case) }

      before do
        this_case.update!(blurb: 'A new blurb')
        version = this_case.versions.last
        raise 'expected PaperTrail to record a version' if version.blank?

        post_revert(this_case, version.id)
      end

      it 'redirects to the case page' do
        expect(response).to redirect_to("/cases/#{this_case.slug}")
      end
    end

    context 'when reverting a create version' do
      let(:new_case) { FactoryBot.create(:case) }

      before do
        version_id = new_case.versions.last&.id || 0
        post_revert(new_case, version_id)
      end

      it 'redirects to the previous page' do
        expect(response).to redirect_to('/')
      end
    end
  end
end
