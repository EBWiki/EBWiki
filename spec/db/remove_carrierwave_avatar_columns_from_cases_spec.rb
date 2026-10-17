# frozen_string_literal: true

require Rails.root.join('db/migrate/20261011150000_remove_carrierwave_avatar_columns_from_cases')

RSpec.describe RemoveCarrierwaveAvatarColumnsFromCases do
  let(:migration) { described_class.new }
  let(:image_path) { Rails.root.join('app/assets/images/favicon.jpg') }

  describe '#up' do
    around do |example|
      ENV['EBWIKI_RUN_SLICE_5B_COLUMN_DROP'] = '1'
      example.run
    ensure
      ENV.delete('EBWIKI_RUN_SLICE_5B_COLUMN_DROP')
    end

    before do
      migration.down unless column_exists?(:cases, :avatar)
    end

    after do
      migration.down unless column_exists?(:cases, :avatar)
    end

    it 'refuses to drop columns when a case has avatar but no photo' do
      create(:case).update_columns(avatar: 'legacy.jpg', default_avatar_url: 'http://example.com/x.jpg')

      expect { migration.up }
        .to raise_error(
          ActiveRecord::MigrationError,
          /Refusing to drop legacy case photo columns.*1 case/
        )

      expect(column_exists?(:cases, :avatar)).to be(true)
    end

    it 'refuses when only default_avatar_url is set without a photo' do
      create(:case).update_columns(avatar: nil, default_avatar_url: 'http://example.com/x.jpg')

      expect { migration.up }.to raise_error(ActiveRecord::MigrationError)

      expect(column_exists?(:cases, :default_avatar_url)).to be(true)
    end

    it 'skips dropping columns without ALLOW_CASE_AVATAR_COLUMN_DROP outside test env' do
      migrated = create(:case)
      migrated.update_columns(avatar: 'legacy.jpg', default_avatar_url: nil, remove_avatar: nil)
      migrated.photo.attach(
        io: File.open(image_path),
        filename: 'favicon.jpg',
        content_type: 'image/jpeg'
      )

      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      ENV.delete('ALLOW_CASE_AVATAR_COLUMN_DROP')

      expect { migration.up }.not_to raise_error

      expect(column_exists?(:cases, :avatar)).to be(true)
    ensure
      ENV.delete('ALLOW_CASE_AVATAR_COLUMN_DROP')
    end

    it 'drops avatar columns when allowed and no case is missing a photo' do
      migrated = create(:case)
      migrated.update_columns(avatar: 'legacy.jpg', default_avatar_url: nil, remove_avatar: nil)
      migrated.photo.attach(
        io: File.open(image_path),
        filename: 'favicon.jpg',
        content_type: 'image/jpeg'
      )
      create(:case).update_columns(avatar: nil, default_avatar_url: nil, remove_avatar: nil)

      expect { migration.up }.not_to raise_error

      expect(column_exists?(:cases, :avatar)).to be(false)
      expect(column_exists?(:cases, :default_avatar_url)).to be(false)
      expect(column_exists?(:cases, :remove_avatar)).to be(false)
    end

    it 'runs up, down, and up again when data is safe' do
      migrated = create(:case)
      migrated.update_columns(avatar: 'legacy.jpg', default_avatar_url: nil, remove_avatar: nil)
      migrated.photo.attach(
        io: File.open(image_path),
        filename: 'favicon.jpg',
        content_type: 'image/jpeg'
      )

      expect { migration.up }.not_to raise_error
      expect(column_exists?(:cases, :avatar)).to be(false)

      expect { migration.down }.not_to raise_error
      expect(column_exists?(:cases, :avatar)).to be(true)
      expect(column_exists?(:cases, :default_avatar_url)).to be(true)
      expect(column_exists?(:cases, :remove_avatar)).to be(true)

      expect { migration.up }.not_to raise_error
      expect(column_exists?(:cases, :avatar)).to be(false)
    end

    it 'drops columns in production when ALLOW_CASE_AVATAR_COLUMN_DROP is set' do
      migrated = create(:case)
      migrated.update_columns(avatar: 'legacy.jpg', default_avatar_url: nil, remove_avatar: nil)
      migrated.photo.attach(
        io: File.open(image_path),
        filename: 'favicon.jpg',
        content_type: 'image/jpeg'
      )

      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      ENV['ALLOW_CASE_AVATAR_COLUMN_DROP'] = '1'

      expect { migration.up }.not_to raise_error
      expect(column_exists?(:cases, :avatar)).to be(false)
    ensure
      ENV.delete('ALLOW_CASE_AVATAR_COLUMN_DROP')
    end
  end

  def column_exists?(table, column)
    ActiveRecord::Base.connection.column_exists?(table, column)
  end
end
