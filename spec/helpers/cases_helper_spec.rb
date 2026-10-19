# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe CasesHelper, type: :helper do
  let(:image_path) { Rails.root.join('app/assets/images/favicon.jpg') }
  let(:uploaded_file) { Rack::Test::UploadedFile.new(image_path, 'image/jpeg') }

  before do
    Rails.application.routes.default_url_options[:host] = 'www.example.com'
  end

  describe '#case_photo_url' do
    context 'when Active Storage photo is attached' do
      let(:case_record) { create(:case) }

      before do
        case_record.photo.attach(
          io: File.open(image_path),
          filename: 'favicon.jpg',
          content_type: 'image/jpeg'
        )
      end

      it 'returns a variant URL for :large' do
        url = helper.case_photo_url(case_record, :large)
        expect(url).to include('/rails/active_storage/')
      end

      it 'returns a variant URL for :medium' do
        url = helper.case_photo_url(case_record, :medium)
        expect(url).to include('/rails/active_storage/')
      end

      it 'returns a variant URL for :small' do
        url = helper.case_photo_url(case_record, :small)
        expect(url).to include('/rails/active_storage/')
      end
    end

    context 'when only CarrierWave avatar is present' do
      let(:case_record) { create(:case) }

      before do
        case_record.avatar = uploaded_file
        case_record.save!
        case_record.reload
      end

      it 'returns the large_avatar URL for :large' do
        url = case_record.avatar.large_avatar.url
        expect(helper.case_photo_url(case_record, :large)).to eq(url)
      end

      it 'returns the medium_avatar URL for :medium' do
        url = case_record.avatar.medium_avatar.url
        expect(helper.case_photo_url(case_record, :medium)).to eq(url)
      end

      it 'returns the small_avatar URL for :small' do
        url = case_record.avatar.small_avatar.url
        expect(helper.case_photo_url(case_record, :small)).to eq(url)
      end
    end

    context 'when neither photo nor avatar is present' do
      let(:case_record) { create(:case) }

      it 'returns nil' do
        expect(helper.case_photo_url(case_record, :large)).to be_nil
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
