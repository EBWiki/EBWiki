# frozen_string_literal: true

require 'digest/md5'
require 'fileutils'

RSpec.describe ActiveStorageBackfill::CasePhotos do
  let(:image_path) { Rails.root.join('app/assets/images/favicon.jpg') }
  let(:uploaded_file) { Rack::Test::UploadedFile.new(image_path, 'image/jpeg') }

  def seed_carrierwave_file(case_record, uploaded_file)
    filename = uploaded_file.original_filename
    update_legacy_case_photo_columns(case_record, avatar: filename)
    store_dir = Rails.root.join("public/uploads/case/avatar/#{case_record.id}")
    FileUtils.mkdir_p(store_dir)
    FileUtils.cp(uploaded_file.path, store_dir.join(filename))
  end

  describe '#call' do
    it 'attaches photo with the same byte checksum as the CarrierWave avatar' do
      case_record = create(:case)
      seed_carrierwave_file(case_record, uploaded_file)
      source_bytes = File.binread(image_path)
      expected_checksum = Digest::MD5.base64digest(source_bytes)

      counts = described_class.call

      case_record.reload
      expect(case_record.photo).to be_attached
      expect(case_record.photo.blob.checksum).to eq(expected_checksum)
      expect(counts[:attached]).to eq(1)
      expect(counts[:scanned]).to eq(1)
    end

    it 'is idempotent on a second run' do
      case_record = create(:case)
      seed_carrierwave_file(case_record, uploaded_file)

      described_class.call
      case_record.reload
      first_blob_id = case_record.photo.blob.id

      counts = described_class.call

      case_record.reload
      expect(case_record.photo.blob.id).to eq(first_blob_id)
      expect(counts[:attached]).to eq(0)
      expect(counts[:skipped_already_attached]).to eq(1)
    end

    it 'skips cases with a blank avatar column' do
      case_record = create(:case)
      update_legacy_case_photo_columns(case_record, avatar: nil)

      counts = described_class.call

      case_record.reload
      expect(case_record.photo).not_to be_attached
      expect(counts[:skipped_blank]).to eq(1)
    end

    it 'counts missing source files without raising' do
      case_record = create(:case)
      update_legacy_case_photo_columns(
        case_record,
        avatar: 'no-such-avatar.jpg',
        default_avatar_url: nil
      )

      counts = nil
      expect { counts = described_class.call }.not_to raise_error

      expect(counts[:missing_file]).to eq(1)
      expect(case_record.reload.photo).not_to be_attached
    end

    it 'does not attach when dry_run is true' do
      case_record = create(:case)
      seed_carrierwave_file(case_record, uploaded_file)

      counts = described_class.call(dry_run: true)

      case_record.reload
      expect(case_record.photo).not_to be_attached
      expect(counts[:attached]).to eq(0)
      expect(counts[:scanned]).to eq(1)
      expect(described_class.summary_line(counts)).to include('scanned=1', 'attached=0')
    end

    it 'attaches photo when avatar bytes are read from fog storage (no local path)' do
      case_record = create(:case)
      update_legacy_case_photo_columns(
        case_record,
        avatar: 'remote-avatar.jpg',
        default_avatar_url: nil
      )
      fog_bytes = File.binread(image_path)
      fog_file = instance_double(
        CarrierWave::Storage::Fog::File,
        exists?: true,
        read: fog_bytes,
        filename: 'remote-avatar.jpg',
        content_type: 'image/jpeg'
      )
      uploader = instance_double(AvatarUploader, file: fog_file)
      allow(AvatarUploader).to receive(:new).and_return(uploader)
      allow(uploader).to receive(:retrieve_from_store!)

      relation = Case.where(id: case_record.id)
      allow(Case).to receive(:order).with(:id).and_return(relation)
      allow(relation).to receive(:find_each).and_yield(case_record)

      counts = described_class.call

      case_record.reload
      expect(counts[:missing_file]).to eq(0)
      expect(counts[:attached]).to eq(1)
      expect(case_record.photo).to be_attached
      expect(case_record.photo.blob.checksum).to eq(Digest::MD5.base64digest(fog_bytes))
    end
  end
end
