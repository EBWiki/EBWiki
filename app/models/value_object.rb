# frozen_string_literal: true

# Value object - base
class ValueObject
  def to_s
    raise NotImplementedError
  end

  # rubocop:disable Style/RedundantSelf
  def ==(other)
    self.class == other.class && self.to_s == other.to_s
  end
  # rubocop:enable Style/RedundantSelf
end
