# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable Metrics/BlockLength.
RSpec.describe 'Cases', type: :request do
  describe 'GET /cases' do
    context 'will get list of cases' do
      before { get '/cases', params: {}, headers: {} }

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the list of cases' do
        expect(response.body).to include('cases')
      end
    end
  end

  describe 'GET /cases/:slug' do
    let(:_case) { create(:case) }

    context 'will get case page' do
      before { get "/cases/#{_case.slug}", params: {}, headers: {} }

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the case page' do
        expect(response.body).to include(_case.title)
      end
    end
  end

  describe 'GET /cases/new' do
    let(:user) { create(:user) }
    let(:redis) { MockRedis.new }

    before do
      sign_in user
      get '/cases/new', params: {}, headers: {}
    end

    it 'will return status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'will return the agency form' do
      expect(response.body).to include('New Case')
    end
  end

  describe 'GET /cases/:slug/edit' do
    let(:user) { create(:user) }
    let(:_case) { create(:case) }

    before do
      sign_in user
      get "/cases/#{_case.slug}/edit", params: {}, headers: {}
    end

    it 'will return status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'will return the case form' do
      expect(response.body).to include 'Summary'
    end
  end

  describe 'POST /cases' do
    let(:user) { create(:user) }
    let(:params) { { case: attributes_for(:case) } }
    let(:bad_params) { { case: { city: 'Beaumont' } } }

    context 'when the case is successfully saved' do
      before do
        sign_in user
        post '/cases', params: params, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will navigate to the case show page' do
        expect(response.body).to include(params[:case][:title])
      end
    end

    context 'when the case has errors' do
      before do
        sign_in user
        post '/cases', params: bad_params, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will navigate to the case form' do
        expect(response.body).to include('New Case')
      end
    end
  end

  describe 'PATCH /cases/:slug' do
    let(:user) { create(:user) }
    let(:_case) { create(:case) }
    let(:params) { { case: { city: 'Albany' } } }
    let(:bad_params) { { case: { date: Date.tomorrow } } }

    context 'when the case is successfully updated' do
      before do
        sign_in user
        patch "/cases/#{_case.slug}", params: params, headers: {}
      end

      it 'will redirect to the case show page' do
        expect(response).to be_redirect
      end
    end

    context 'when the case has errors' do
      before do
        sign_in user
        patch "/cases/#{_case.slug}", params: bad_params, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will navigate to the case form' do
        expect(response.body).to include('Editing')
      end
    end
  end

  describe 'GET /cases/:slug/followers' do
    let(:users) { create_list(:user, 5) }
    let(:_case) { create(:case) }

    context 'will get followers page' do
      before do
        users.map { |user| user.follow(_case) }
        get "/cases/#{_case.slug}/followers"
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return a list of followers' do
        expect(response.body).to include('followers')
      end
    end
  end

  describe 'GET /cases/:slug/history' do
    def history_list_items(body)
      body.scan(%r{<li>\s*<b>Date:</b>.*?</li>}m)
    end

    context 'will get history page' do
      let(:_case) { create(:case) }

      before { get "/cases/#{_case.slug}/history", params: {}, headers: {} }

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the history of the case' do
        expect(response.body).to include('history')
      end
    end

    context 'when duplicate version rows exist for one edit', versioning: true do
      let(:_case) { create(:case) }
      let(:edit_summary) do
        'Added article discussing how David Silva was exonerated by testimony from two doctors'
      end

      before do
        _case.update!(overview: 'Updated overview', summary: edit_summary)
        source = _case.versions.where(event: 'update').last
        PaperTrail::Version.create!(
          item_type: 'Case',
          item_id: _case.id,
          event: source.event,
          whodunnit: source.whodunnit,
          comment: source.comment,
          created_at: source.created_at,
          object: source.object,
          object_changes: source.object_changes
        )
      end

      it 'lists each history event once' do
        get "/cases/#{_case.slug}/history", params: {}, headers: {}

        items = history_list_items(response.body)
        matching = items.select { |item| item.include?(edit_summary) }

        expect(matching.size).to eq(1)
        expect(items.uniq.size).to eq(items.size)
      end
    end

    context 'when a case has links and versioned edits', versioning: true do
      let(:_case) { create(:case) }

      before do
        link = _case.links.create!(url: 'http://example.com/source', title: 'Source')
        _case.update!(
          overview: 'Updated overview',
          summary: 'Added a related link',
          links_attributes: [{
            id: link.id,
            url: 'http://example.com/updated',
            title: 'Updated link'
          }]
        )
      end

      it 'does not duplicate history entries on the page' do
        get "/cases/#{_case.slug}/history", params: {}, headers: {}

        items = history_list_items(response.body)
        expect(items.size).to eq(_case.reload.versions.count)
        expect(items.uniq.size).to eq(items.size)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength.
