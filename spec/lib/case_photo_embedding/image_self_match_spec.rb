# frozen_string_literal: true

require 'open3'
require 'rails_helper'

RSpec.describe 'Case photo embedding self-match', :embedding_model do
  let(:fixture_path) { Rails.root.join('spec/fixtures/files/sample_case_photo.png') }
  let(:python_path) { Rails.root.join('lib/case_photo_embedding/python') }

  def embed_file(path)
    env = {
      'PYTHONPATH' => python_path.to_s,
      'HF_HOME' => ENV.fetch('HF_HOME', '/tmp/huggingface'),
      'TRANSFORMERS_CACHE' => ENV.fetch('TRANSFORMERS_CACHE', '/tmp/huggingface')
    }
    stdout, status = Open3.capture2e(env, 'python3', '-m', 'case_photo_embedding.embed_cli', path.to_s)
    raise stdout unless status.success?

    JSON.parse(stdout.lines.last)
  end

  it 'returns the same case first when ranked by its own image embedding' do
    vector = embed_file(fixture_path)
    anchor = create(:case, photo_status: 'shown', photo_url: 'https://example.com/anchor.jpg')
    anchor.update_column(:photo_embedding, vector)

    decoy = create(:case, photo_status: 'shown', photo_url: 'https://example.com/decoy.jpg')
    decoy.update_column(:photo_embedding, vector.reverse)

    results = CasePhotoEmbedding::SimilarCases.ranked_by_embedding(vector, limit: 3)

    expect(results.first).to eq(anchor)
  end
end
