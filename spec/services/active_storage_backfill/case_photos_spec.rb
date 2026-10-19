# frozen_string_literal: true

require 'digest/md5'

RSpec.describe ActiveStorageBackfill::CasePhotos do
  let(:image_path) { Rails.root.join('app/assets/images/favicon.jpg') }
  let(:uploaded_file) { Rack::Test::UploadedFile.new(image_path, 'image/jpeg') }

  def attach_carrierwave_avatar(case_record)
    case_record.avatar = uploaded_file
    case_record.save!
    case_record.reload
  end

  describe '#call' do
    it 'attaches photo with the same byte checksum as the CarrierWave avatar' do
      case_record = create(:case)
      attach_carrierwave_avatar(case_record)
      source_bytes = File.binread(case_record.avatar.path)
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
      attach_carrierwave_avatar(case_record)

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
      case_record.update_column(:avatar, nil)

      counts = described_class.call

      case_record.reload
      expect(case_record.photo).not_to be_attached
      expect(counts[:skipped_blank]).to eq(1)
    end

    it 'counts missing source files without raising' do
      case_record = create(:case)
      case_record.update_columns(avatar: 'no-such-avatar.jpg', default_avatar_url: nil)

      counts = nil
      expect { counts = described_class.call }.not_to raise_error

      expect(counts[:missing_file]).to eq(1)
      expect(case_record.reload.photo).not_to be_attached
    end

    it 'does not attach when dry_run is true' do
      case_record = create(:case)
      attach_carrierwave_avatar(case_record)

      counts = described_class.call(dry_run: true)

      case_record.reload
      expect(case_record.photo).not_to be_attached
      expect(counts[:attached]).to eq(0)
      expect(counts[:scanned]).to eq(1)
      expect(described_class.summary_line(counts)).to include('scanned=1', 'attached=0')
    end

    it 'attaches photo when avatar bytes are read from fog storage (no local path)' do
      case_record = create(:case)
      case_record.update_columns(avatar: 'remote-avatar.jpg', default_avatar_url: nil)
      fog_bytes = File.binread(image_path)
      fog_file = instance_double(
        CarrierWave::Storage::Fog::File,
        exists?: true,
        read: fog_bytes,
        filename: 'remote-avatar.jpg',
        content_type: 'image/jpeg'
      )
      allow(case_record.avatar).to receive(:file).and_return(fog_file)

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
