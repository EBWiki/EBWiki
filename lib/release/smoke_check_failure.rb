# frozen_string_literal: true

module Release
  class SmokeCheckFailure < StandardError
    attr_reader :step

    def initialize(step, message)
      @step = step
      super(message)
    end
  end
end
