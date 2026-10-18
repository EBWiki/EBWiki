# frozen_string_literal: true

require_relative '../error_reporter'

module Release
  class Rollback
    # Runs rollback commands when execute mode is enabled (stubbed in specs).
    class CommandExecutor
      ExecutionResult = Data.define(:success, :message)

      NETWORK_ERRORS = RailwayGraphqlClient::NETWORK_ERRORS

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
        perform_railway_rollback(command)
        ExecutionResult.new(success: true, message: 'Railway rollback accepted')
      rescue RollbackError => e
        ExecutionResult.new(success: false, message: e.message)
      rescue *NETWORK_ERRORS => e
        report_railway_network_error(e)
        ExecutionResult.new(success: false, message: "Railway rollback failed: #{e.message}")
      end

      def perform_railway_rollback(command)
        RailwayApi.perform_rollback(
          deployment_id: command.deployment_id,
          service_name: command.service_name,
          environment_name: command.environment_slug
        )
      end

      def report_railway_network_error(error)
        Release::ErrorReporter.report(
          event: 'release_rollback_network',
          message: error.message,
          context: { client: 'CommandExecutor', step: 'execute_railway' }
        )
      end
    end
  end
end
