# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Case photo image suppression when hidden', type: :request do
  def avatar_upload_url
    CasePhotoTestData.attach_test_avatar(create(:case)).avatar.large_avatar.url
  end

  let(:avatar_url) { avatar_upload_url }

  context 'on the case detail page' do
    let(:this_case) do
      CasePhotoTestData.attach_test_avatar(create(:case)).tap do |record|
        record.update!(photo_status: :hidden, photo_url: nil)
      end
    end

    it 'shows the name card and not the legacy avatar' do
      get case_path(this_case)
      expect(response.body).to include('case-photo-name-card')
      expect(response.body).not_to include(avatar_url)
    end
  end

  context 'on the cases list thumbnail' do
    let(:this_case) do
      CasePhotoTestData.attach_test_avatar(create(:case)).tap do |record|
        record.update!(photo_status: :hidden, photo_url: 'https://example.com/photos/victim.jpg')
      end
    end

    it 'shows the name card and not the link photo or avatar' do
      this_case
      get cases_path
      expect(response.body).to include('case-photo-name-card--thumbnail')
      expect(response.body).not_to include('https://example.com/photos/victim.jpg')
      expect(response.body).not_to include(avatar_url)
    end
  end
end
