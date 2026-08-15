# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Friendly photos', type: :request do
  let(:user) { create(:user) }
  let(:this_case) { create(:case) }

  before { create(:subject, case: this_case, name: 'Walter Scott') }

  describe 'GET /friendly_photos' do
    it 'requires a signed-in editor' do
      get friendly_photos_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'lists cases that need a better photo' do
      sign_in user
      get friendly_photos_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Walter Scott')
      expect(response.body).to include('Find photos')
    end
  end

  describe 'GET /friendly_photos/:id' do
    it 'shows the current photo and search action' do
      sign_in user
      get friendly_photo_path(this_case)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Search Wikimedia for a friendly photo')
      expect(response.body).to include('Walter Scott')
    end
  end

  describe 'POST /friendly_photos/:id/search' do
    it 'stores search results and returns to the review page' do
      sign_in user
      candidate = create(:photo_candidate, case: this_case)
      allow(FriendlyPhotos::CandidateSearch).to receive(:call).and_return([candidate])

      post search_friendly_photo_path(this_case)

      expect(FriendlyPhotos::CandidateSearch).to have_received(:call).with(this_case: this_case)
      expect(response).to redirect_to(friendly_photo_path(this_case))
      follow_redirect!
      expect(response.body).to include('Found 1 images')
    end
  end

  describe 'PATCH /friendly_photos/:id/classify' do
    it 'marks the current photo as a mugshot' do
      sign_in user
      patch classify_friendly_photo_path(this_case), params: { avatar_kind: 'mugshot' }

      expect(this_case.reload).to be_mugshot
      expect(response).to redirect_to(friendly_photo_path(this_case))
    end
  end

  describe 'POST /friendly_photos/:id/apply' do
    it 'applies a reviewed candidate' do
      sign_in user
      candidate = create(:photo_candidate, case: this_case)
      allow(FriendlyPhotos::ApplyCandidate).to receive(:call).and_return(
        FriendlyPhotos::ApplyCandidate::Result.new(success: true, error: nil)
      )

      post apply_friendly_photo_path(this_case), params: { photo_candidate_id: candidate.id }

      expect(FriendlyPhotos::ApplyCandidate).to have_received(:call)
        .with(this_case: this_case, candidate: candidate)
      expect(response).to redirect_to(friendly_photo_path(this_case))
    end
  end

  describe 'POST /friendly_photos/:id/reject' do
    it 'rejects a candidate' do
      sign_in user
      candidate = create(:photo_candidate, case: this_case)

      post reject_friendly_photo_path(this_case), params: { photo_candidate_id: candidate.id }

      expect(candidate.reload).to be_rejected
    end
  end
end
