# frozen_string_literal: true

module VectorSearch
  module_function

  def cosine_distance(left, right)
    dot, norm_left, norm_right = dot_and_norms(left, right)
    denom = Math.sqrt(norm_left) * Math.sqrt(norm_right)
    return 1.0 if denom.zero?

    1.0 - (dot / denom)
  end

  def dot_and_norms(left, right)
    dot = 0.0
    norm_left = 0.0
    norm_right = 0.0
    left.each_with_index do |val, idx|
      other = right[idx]
      dot += val * other
      norm_left += val * val
      norm_right += other * other
    end
    [dot, norm_left, norm_right]
  end
  private_class_method :dot_and_norms

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
    Array.new(dim) { |idx| ((seed + (idx * 17)) % 100) / 1000.0 }
  end
end
