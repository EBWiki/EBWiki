# frozen_string_literal: true

describe 'active_storage:case_avatar_drop_check' do
  include_context 'rake'

  let(:task_path) { 'lib/tasks/active_storage_backfill' }

  it 'prints zero and exits 0 when every case is safe' do
    expect { subject.invoke }.to output("unsafe_case_count=0\n").to_stdout
  end

  it 'prints the count and exits 1 when a case is unsafe' do
    update_legacy_case_photo_columns(create(:case), avatar: 'legacy-only.jpg')

    expect { subject.invoke }.to raise_error(SystemExit) do |error|
      expect(error.status).to eq(1)
    end
  end
end
