# frozen_string_literal: true

require Rails.root.join('db/migrate/20261011150000_remove_carrierwave_avatar_columns_from_cases')

RSpec.describe ActiveStorageCutover::CaseAvatarDropGuard do
  let(:column_drop_migration) { RemoveCarrierwaveAvatarColumnsFromCases.new }

  before do
    column_drop_migration.down unless ActiveRecord::Base.connection.column_exists?(:cases, :avatar)
  end
  let(:image_path) { Rails.root.join('app/assets/images/favicon.jpg') }
  let(:uploaded_file) { Rack::Test::UploadedFile.new(image_path, 'image/jpeg') }

  describe '.unsafe_case_count' do
    it 'counts cases with a legacy avatar and no photo attachment' do
      blocked = create(:case)
      blocked.update_columns(avatar: 'legacy-only.jpg', default_avatar_url: nil)

      safe_blank = create(:case)
      safe_blank.update_columns(avatar: nil)

      with_photo = create(:case)
      with_photo.avatar = uploaded_file
      with_photo.save!
      with_photo.photo.attach(
        io: File.open(image_path),
        filename: 'favicon.jpg',
        content_type: 'image/jpeg'
      )

      expect(described_class.unsafe_case_count).to eq(1)
    end
  end

  describe '.refuse_if_unsafe!' do
    it 'raises with the affected case count when any case is missing a photo' do
      create(:case).update_columns(avatar: 'still-on-carrierwave.jpg')

      expect { described_class.refuse_if_unsafe! }
        .to raise_error(ActiveRecord::MigrationError, /Refusing to drop cases\.avatar: 1 case/)
    end

    it 'allows the drop when every legacy avatar has a photo or avatar is blank' do
      case_with_photo = create(:case)
      case_with_photo.update_columns(avatar: 'migrated.jpg')
      case_with_photo.photo.attach(
        io: File.open(image_path),
        filename: 'favicon.jpg',
        content_type: 'image/jpeg'
      )

      create(:case).update_columns(avatar: nil)

      expect { described_class.refuse_if_unsafe! }.not_to raise_error
    end
  end
end
