# frozen_string_literal: true

module Release
  class Rollback
    # Runs shell commands when rollback is executed (stubbed in specs).
    class CommandExecutor
      ExecutionResult = Data.define(:success, :message)

      def call(commands)
        commands.each do |command|
          next if system(command)

          return ExecutionResult.new(success: false, message: "Command failed: #{command}")
        end
        ExecutionResult.new(success: true, message: 'Rollback commands finished')
      end
    end
  end
end
