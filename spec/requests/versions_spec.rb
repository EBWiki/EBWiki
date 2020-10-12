# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Versions', type: :request do
  describe 'POST /revert' do
    let(:this_case) { FactoryBot.create(:case) }

    before do
      this_case.update_attributes!(latitude: 50)
      post "/cases/#{this_case.id}/versions/1/revert",
           params: {},
           headers: {
             "HTTP_REFERER": '/'
           }
    end

    context 'reverts the version of the case' do
      it 'redirects to the previous page' do
        expect(response).to redirect_to('/')
      end
    end
  end
end
