# frozen_string_literal: true

require Rails.root.join('db/migrate/20261011150000_remove_carrierwave_avatar_columns_from_cases')

RSpec.describe RemoveCarrierwaveAvatarColumnsFromCases do
  let(:migration) { described_class.new }
  let(:image_path) { Rails.root.join('app/assets/images/favicon.jpg') }
  let(:migration_version) { 20_261_011_150_000 }
  let(:migrations_path) { Rails.root.join('db/migrate') }

  def column_exists?(table, column)
    ActiveRecord::Base.connection.column_exists?(table, column)
  end

  def schema_version_recorded?(version)
    ActiveRecord::Base.connection.select_value(
      ActiveRecord::Base.sanitize_sql_array(
        ['SELECT 1 FROM schema_migrations WHERE version = ?', version.to_s]
      )
    ).present?
  end

  def migrate_up_through_guarded_migration(env: 'production', allow_drop: nil)
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(env))
    if allow_drop.nil?
      ENV.delete('ALLOW_CASE_AVATAR_COLUMN_DROP')
    else
      ENV['ALLOW_CASE_AVATAR_COLUMN_DROP'] = allow_drop
    end

    context = ActiveRecord::MigrationContext.new(migrations_path)
    context.up(migration_version)
  ensure
    ENV.delete('ALLOW_CASE_AVATAR_COLUMN_DROP')
  end

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
      update_legacy_case_photo_columns(
        create(:case),
        avatar: 'legacy.jpg',
        default_avatar_url: 'http://example.com/x.jpg'
      )

      expect { migration.up }
        .to raise_error(
          ActiveRecord::MigrationError,
          /Refusing to drop legacy case photo columns.*1 case/
        )

      expect(column_exists?(:cases, :avatar)).to be(true)
    end

    it 'refuses when only default_avatar_url is set without a photo' do
      update_legacy_case_photo_columns(
        create(:case),
        avatar: nil,
        default_avatar_url: 'http://example.com/x.jpg'
      )

      expect { migration.up }.to raise_error(ActiveRecord::MigrationError)

      expect(column_exists?(:cases, :default_avatar_url)).to be(true)
    end

    it 'raises without ALLOW_CASE_AVATAR_COLUMN_DROP outside test env' do
      migrated = create(:case)
      update_legacy_case_photo_columns(
        migrated,
        avatar: 'legacy.jpg',
        default_avatar_url: nil,
        remove_avatar: nil
      )
      migrated.photo.attach(
        io: File.open(image_path),
        filename: 'favicon.jpg',
        content_type: 'image/jpeg'
      )

      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      ENV.delete('ALLOW_CASE_AVATAR_COLUMN_DROP')

      expect { migration.up }
        .to raise_error(ActiveRecord::MigrationError, /ALLOW_CASE_AVATAR_COLUMN_DROP=1/)

      expect(column_exists?(:cases, :avatar)).to be(true)
    end

    it 'does not record schema_migrations when ALLOW switch is unset in production' do
      migrated = create(:case)
      update_legacy_case_photo_columns(
        migrated,
        avatar: 'legacy.jpg',
        default_avatar_url: nil,
        remove_avatar: nil
      )
      migrated.photo.attach(
        io: File.open(image_path),
        filename: 'favicon.jpg',
        content_type: 'image/jpeg'
      )

      ActiveRecord::Base.connection.execute(
        ActiveRecord::Base.sanitize_sql_array(
          ['DELETE FROM schema_migrations WHERE version = ?', migration_version.to_s]
        )
      )

      expect do
        migrate_up_through_guarded_migration(env: 'production', allow_drop: nil)
      end.to raise_error(StandardError, /ALLOW_CASE_AVATAR_COLUMN_DROP=1/)

      expect(schema_version_recorded?(migration_version)).to be(false)
      expect(column_exists?(:cases, :avatar)).to be(true)
    end

    it 'raises the guard error in production when ALLOW is set but data is unsafe' do
      update_legacy_case_photo_columns(create(:case), avatar: 'legacy.jpg', default_avatar_url: nil)

      ActiveRecord::Base.connection.execute(
        ActiveRecord::Base.sanitize_sql_array(
          ['DELETE FROM schema_migrations WHERE version = ?', migration_version.to_s]
        )
      )

      expect do
        migrate_up_through_guarded_migration(env: 'production', allow_drop: '1')
      end.to raise_error(StandardError, /Refusing to drop legacy case photo columns/)

      expect(column_exists?(:cases, :avatar)).to be(true)
    end

    it 'drops avatar columns when allowed and no case is missing a photo' do
      migrated = create(:case)
      update_legacy_case_photo_columns(
        migrated,
        avatar: 'legacy.jpg',
        default_avatar_url: nil,
        remove_avatar: nil
      )
      migrated.photo.attach(
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

      expect { migration.up }.not_to raise_error

      expect(column_exists?(:cases, :avatar)).to be(false)
      expect(column_exists?(:cases, :default_avatar_url)).to be(false)
      expect(column_exists?(:cases, :remove_avatar)).to be(false)
    end

    it 'runs up, down, and up again when data is safe' do
      migrated = create(:case)
      update_legacy_case_photo_columns(
        migrated,
        avatar: 'legacy.jpg',
        default_avatar_url: nil,
        remove_avatar: nil
      )
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
      update_legacy_case_photo_columns(
        migrated,
        avatar: 'legacy.jpg',
        default_avatar_url: nil,
        remove_avatar: nil
      )
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
end
