# frozen_string_literal: true

RSpec.describe ActiveStorageCutover::CaseAvatarDropGuard do
  let(:image_path) { Rails.root.join('app/assets/images/favicon.jpg') }

  describe '.unsafe_case_count' do
    it 'counts cases with a legacy avatar and no photo attachment' do
      blocked = create(:case)
      update_legacy_case_photo_columns(blocked, avatar: 'legacy-only.jpg', default_avatar_url: nil)

      safe_blank = create(:case)
      update_legacy_case_photo_columns(
        safe_blank,
        avatar: nil,
        default_avatar_url: nil,
        remove_avatar: nil
      )

      with_photo = create(:case)
      update_legacy_case_photo_columns(
        with_photo,
        avatar: 'migrated.jpg',
        default_avatar_url: nil,
        remove_avatar: nil
      )
      with_photo.photo.attach(
        io: File.open(image_path),
        filename: 'favicon.jpg',
        content_type: 'image/jpeg'
      )

      expect(described_class.unsafe_case_count).to eq(1)
    end

    it 'counts cases with only default_avatar_url set and no photo attachment' do
      update_legacy_case_photo_columns(
        create(:case),
        avatar: nil,
        default_avatar_url: 'http://example.com/legacy.jpg'
      )

      expect(described_class.unsafe_case_count).to eq(1)
    end

    it 'does not count cases with remove_avatar true when legacy columns are blank' do
      update_legacy_case_photo_columns(
        create(:case),
        avatar: nil,
        default_avatar_url: nil,
        remove_avatar: true
      )

      expect(described_class.unsafe_case_count).to eq(0)
    end
  end

  describe '.refuse_if_unsafe!' do
    it 'raises with the affected case count when any case is missing a photo' do
      update_legacy_case_photo_columns(create(:case), avatar: 'still-on-carrierwave.jpg')

      expect { described_class.refuse_if_unsafe! }
        .to raise_error(
          ActiveRecord::MigrationError,
          /Refusing to drop legacy case photo columns.*1 case/
        )
    end

    it 'raises when default_avatar_url is set without a photo' do
      update_legacy_case_photo_columns(
        create(:case),
        avatar: nil,
        default_avatar_url: 'http://example.com/x.jpg'
      )

      expect { described_class.refuse_if_unsafe! }
        .to raise_error(ActiveRecord::MigrationError, /1 case/)
    end

    it 'allows the drop when every legacy avatar has a photo or avatar is blank' do
      case_with_photo = create(:case)
      update_legacy_case_photo_columns(
        case_with_photo,
        avatar: 'migrated.jpg',
        default_avatar_url: nil,
        remove_avatar: nil
      )
      case_with_photo.photo.attach(
        io: File.open(image_path),
        filename: 'favicon.jpg',
        content_type: 'image/jpeg'
      )

      update_legacy_case_photo_columns(
        create(:case),
        avatar: nil,
        default_avatar_url: nil,
        remove_avatar: nil
      )

      expect { described_class.refuse_if_unsafe! }.not_to raise_error
    end
  end
end
