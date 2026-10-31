# frozen_string_literal: true

module Release
  ShellCommand = Data.define(:argv, :description) do
    def to_s
      description || argv.join(' ')
    end
  end
end
