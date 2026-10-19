# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasesHelper, type: :helper do
  let(:image_path) { Rails.root.join('app/assets/images/favicon.jpg') }

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

    context 'when no photo is attached' do
      let(:case_record) { create(:case) }

      it 'returns nil' do
        expect(helper.case_photo_url(case_record, :large)).to be_nil
      end
    end
  end
end
