# frozen_string_literal: true

require Rails.root.join('db/migrate/20261011150000_remove_carrierwave_avatar_columns_from_cases')

RSpec.describe RemoveCarrierwaveAvatarColumnsFromCases do
  let(:migration) { described_class.new }
  let(:image_path) { Rails.root.join('app/assets/images/favicon.jpg') }

  describe '#up' do
    before do
      migration.down unless column_exists?(:cases, :avatar)
    end

    after do
      migration.down unless column_exists?(:cases, :avatar)
    end

    it 'refuses to drop columns when a case has avatar but no photo' do
      create(:case).update_columns(avatar: 'legacy.jpg', default_avatar_url: 'http://example.com/x.jpg')

      expect { migration.up }
        .to raise_error(ActiveRecord::MigrationError, /Refusing to drop cases\.avatar: 1 case/)

      expect(column_exists?(:cases, :avatar)).to be(true)
    end

    it 'drops avatar columns when no case is missing a photo' do
      migrated = create(:case)
      migrated.update_columns(avatar: 'legacy.jpg')
      migrated.photo.attach(
        io: File.open(image_path),
        filename: 'favicon.jpg',
        content_type: 'image/jpeg'
      )
      create(:case).update_columns(avatar: nil)

      expect { migration.up }.not_to raise_error

      expect(column_exists?(:cases, :avatar)).to be(false)
      expect(column_exists?(:cases, :default_avatar_url)).to be(false)
      expect(column_exists?(:cases, :remove_avatar)).to be(false)
    end
  end

  def column_exists?(table, column)
    ActiveRecord::Base.connection.column_exists?(table, column)
  end
end
