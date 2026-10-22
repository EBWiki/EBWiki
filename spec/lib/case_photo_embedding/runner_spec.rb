# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasePhotoEmbedding::Runner do
  it 'raises when the Python job exits non-zero' do
    allow(Open3).to receive(:capture3).and_return(['', 'boom', instance_double(Process::Status, success?: false, exitstatus: 2)])

    expect do
      described_class.new.call
    end.to raise_error(CasePhotoEmbedding::Runner::EmbedJobFailed)
  end

  it 'returns the JSON summary from the last stdout line' do
    stdout = <<~OUT
      info line
      {"shown_count":2,"embedded_count":2,"error_count":0}
    OUT
    allow(Open3).to receive(:capture3).and_return([stdout, '', instance_double(Process::Status, success?: true)])

    summary = described_class.new.call

    expect(summary).to eq(shown_count: 2, embedded_count: 2, error_count: 0)
  end
end
