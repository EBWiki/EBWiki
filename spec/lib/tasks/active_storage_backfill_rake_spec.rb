# frozen_string_literal: true

describe 'active_storage:backfill_case_photos' do
  include_context 'rake'

  let(:task_path) { 'lib/tasks/active_storage_backfill' }
  let(:image_path) { Rails.root.join('app/assets/images/favicon.jpg') }

  before do
    case_record = create(:case)
    case_record.avatar = Rack::Test::UploadedFile.new(image_path, 'image/jpeg')
    case_record.save!
  end

  it 'invokes the backfill service' do
    expect(ActiveStorageBackfill::CasePhotos).to receive(:call)
      .with(dry_run: false, limit: nil)
      .and_return({ attached: 1, scanned: 1 })

    subject.invoke
  end

  it 'honors DRY_RUN=1' do
    ENV['DRY_RUN'] = '1'

    expect(ActiveStorageBackfill::CasePhotos).to receive(:call)
      .with(dry_run: true, limit: nil)
      .and_return({ attached: 0, scanned: 1 })

    subject.invoke
  ensure
    ENV.delete('DRY_RUN')
  end

  it 'honors LIMIT' do
    ENV['LIMIT'] = '3'

    expect(ActiveStorageBackfill::CasePhotos).to receive(:call)
      .with(dry_run: false, limit: '3')
      .and_return({ scanned: 3 })

    subject.invoke
  ensure
    ENV.delete('LIMIT')
  end
end
