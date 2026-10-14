# frozen_string_literal: true

module VectorSearch
  module_function

  def cosine_distance(a, b)
    dot = 0.0
    norm_a = 0.0
    norm_b = 0.0
    a.each_with_index do |val, i|
      other = b[i]
      dot += val * other
      norm_a += val * val
      norm_b += other * other
    end
    denom = Math.sqrt(norm_a) * Math.sqrt(norm_b)
    return 1.0 if denom.zero?

    1.0 - (dot / denom)
  end

  def nearest(vectors_by_id, probe_id: nil, probe_vector: nil, limit: 8)
    probe = probe_vector || vectors_by_id.fetch(probe_id)
    vectors_by_id
      .reject { |id, _| id == probe_id }
      .map { |id, vec| [id, cosine_distance(probe, vec)] }
      .sort_by { |(_, dist)| dist }
      .first(limit)
  end

  # Preview-only: map a text query to a synthetic probe vector (not SigLIP).
  def probe_from_text(text, dim:)
    seed = text.to_s.downcase.strip.bytes.sum
    Array.new(dim) { |i| ((seed + i * 17) % 100) / 1000.0 }
  end
end
