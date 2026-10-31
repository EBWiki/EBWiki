# frozen_string_literal: true

module Release
  # Validates Railway service names used in rollback commands.
  module ResourceName
    PATTERN = /\A[a-z][a-z0-9-]{0,62}\z/

    module_function

    def validate!(value, label:)
      name = value.to_s
      return name if name.match?(PATTERN)

      raise RollbackError,
            "#{label} #{name.inspect} is invalid (use lowercase letters, digits, and hyphens)."
    end
  end
end
