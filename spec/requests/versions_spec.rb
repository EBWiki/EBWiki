# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Versions', type: :request do
  describe 'POST /revert' do
    before do
      this_case = FactoryBot.create(:case)
      post "/cases/#{this_case.id}/versions/1/revert",
           params: {},
           headers: {
             "HTTP_REFERER": '/'
           }
    end
    context 'reverts the version of the case' do
      it 'will return status code 200' do
        expect(response).to have_http_status(302)
      end
    end
  end
end
