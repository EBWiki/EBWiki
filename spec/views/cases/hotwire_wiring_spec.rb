# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'cases Hotwire wiring', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /cases/new' do
    before { get '/cases/new' }

    it 'wires blurb-counter Stimulus on the case form' do
      expect(response.body).to include('data-controller="blurb-counter"')
      expect(response.body).to include('blurb-counter#update')
    end

    it 'wires file-name Stimulus and removes legacy blurb/file jQuery' do
      expect(response.body).to include('data-controller="file-name"')
      expect(response.body).to include('click->file-name#browse')
      expect(response.body).not_to include('displayBlurbCharactersCount')
      expect(response.body).not_to include('$("#case_blurb").keyup')
      expect(response.body).not_to include("onclick=\"$('input[id=lefile_article]').click();\"")
    end

    it 'wires nested-form Stimulus on subjects' do
      expect(response.body).to include('data-controller="nested-form"')
      expect(response.body).to include('data-nested-form-target="container"')
    end
  end

  describe 'GET /cases/:slug' do
    let(:this_case) { create(:case) }

    before do
      3.times { create(:link, linkable: this_case) }
      get "/cases/#{this_case.slug}"
    end

    it 'wires show-more Stimulus and removes link-list jQuery collapse' do
      expect(response.body).to include('data-controller="show-more"')
      expect(response.body).to include('data-show-more-target="item"')
      expect(response.body).not_to include('li:gt(10)')
    end
  end
end
