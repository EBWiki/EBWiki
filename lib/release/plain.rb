# frozen_string_literal: true

module Release
  # Plain Ruby helpers so bin/release-rollback does not need ActiveSupport.
  module Plain
    module_function

    def blank?(value)
      value.nil? || value.to_s.strip.empty?
    end

    def present?(value)
      !blank?(value)
    end

    def presence(value)
      present?(value) ? value : nil
    end

    def env_presence(key)
      presence(ENV.fetch(key, nil))
    end

    def squish(string)
      string.to_s.gsub(/\s+/, ' ').strip
    end
  end
end
