# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Versions', type: :request, versioning: true do
  describe 'POST /revert' do
    let(:this_case) { FactoryBot.create(:case) }

    before do
      this_case.update!(blurb: "A new blurb")
      version_id = this_case.versions[-1].id
      post "/cases/#{this_case.id}/versions/#{version_id}/revert",
           params: {},
           headers: {
             "HTTP_REFERER": '/'
           }
    end

    context 'reverts the version of the case' do
      it 'redirects to the previous page' do
        expect(response).to redirect_to("/cases/#{this_case.slug}")
      end
    end

    context 'when the case is new' do
      before do
        version_id = this_case.versions[-1].id
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
  end
end
