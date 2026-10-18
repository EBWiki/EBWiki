# frozen_string_literal: true

module Release
  class Rollback
    # Runs rollback commands when execute mode is enabled (stubbed in specs).
    class CommandExecutor
      ExecutionResult = Data.define(:success, :message)

      def call(commands)
        commands.each do |command|
          result = execute(command)
          return result unless result.success
        end
        ExecutionResult.new(success: true, message: 'Rollback commands finished')
      end

      private

      def execute(command)
        case command
        when ShellCommand
          execute_shell(command)
        when RailwayRollbackCommand
          execute_railway(command)
        else
          ExecutionResult.new(success: false, message: "Unsupported command #{command.inspect}")
        end
      end

      def execute_shell(command)
        argv = command.argv
        return ExecutionResult.new(success: true, message: 'ok') if system(*argv)

        ExecutionResult.new(success: false, message: "Command failed: #{command}")
      end

      def execute_railway(command)
        RailwayApi.rollback!(deployment_id: command.deployment_id)
        ExecutionResult.new(success: true, message: 'Railway rollback accepted')
      rescue RollbackError => e
        ExecutionResult.new(success: false, message: e.message)
      end
    end
  end
end
