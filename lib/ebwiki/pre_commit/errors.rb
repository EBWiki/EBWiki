# frozen_string_literal: true

module Ebwiki
  module PreCommit
    class Error < StandardError; end

    class UserFacingError < Error
      attr_reader :instructions

      def initialize(message, instructions: nil)
        super(message)
        @instructions = instructions
      end
    end

    class ToolMissingError < UserFacingError; end
    class ToolFailedError < UserFacingError; end
  end
end
