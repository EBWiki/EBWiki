# frozen_string_literal: true

require_relative 'plain'
require_relative 'deployment_id'

module Release
  # Plans and optionally runs a platform rollback (Heroku or Railway).
  class Rollback
    Result = Data.define(:success, :message, :commands)

    def self.run(argv, executor: CommandExecutor.new, output: $stdout, input: $stdin)
      new(argv, executor: executor, output: output, input: input).run
    end

    def initialize(argv, executor:, output:, input: $stdin)
      @argv = argv
      @executor = executor
      @output = output
      @input = input
    end

    def run
      @options = RollbackOptionsBuilder.from_argv(@argv)
      validate!
      planner = Planner.new(@options, output: @output)
      commands = planner.commands
      planner.print(commands)
      return dry_run_result(commands) if @options.dry_run

      execute!(commands)
    rescue RollbackError => e
      @output.puts(e.message)
      Result.new(success: false, message: e.message, commands: [])
    end

    private

    def execute!(commands)
      confirm!
      executor_result = @executor.call(commands)
      Result.new(
        success: executor_result.success,
        message: executor_result.message,
        commands: commands
      )
    end

    def dry_run_result(commands)
      Result.new(
        success: true,
        message: 'Dry run only (pass --execute to run)',
        commands: commands
      )
    end

    def validate!
      raise RollbackError, platform_help if Plain.blank?(@options.platform)

      case @options.platform
      when 'heroku' then validate_heroku!
      when 'railway' then validate_railway!
      else
        raise RollbackError, "Unsupported platform #{@options.platform.inspect}"
      end
    end

    def platform_help
      'Set RELEASE_ROLLBACK_PLATFORM to heroku or railway, ' \
        'or set HEROKU_APP_NAME / RAILWAY_SERVICE.'
    end

    def validate_heroku!
      if Plain.blank?(@options.app_name)
        raise RollbackError, 'Set HEROKU_APP_NAME or RELEASE_HEROKU_APP before rolling back.'
      end

      ResourceName.validate!(@options.app_name, label: 'Heroku app name')
    end

    def validate_railway!
      validate_railway_service!
      validate_railway_environment!
      validate_railway_deployment!
    end

    def validate_railway_service!
      if Plain.blank?(@options.service_name)
        raise RollbackError, 'Set RAILWAY_SERVICE before rolling back on Railway.'
      end

      ResourceName.validate!(@options.service_name, label: 'Railway service name')
    end

    def validate_railway_environment!
      return if Plain.present?(@options.environment_slug)

      raise RollbackError, 'Set RAILWAY_ENVIRONMENT before rolling back on Railway.'
    end

    def validate_railway_deployment!
      if Plain.blank?(@options.deployment_id)
        raise RollbackError, 'Set RAILWAY_ROLLBACK_DEPLOYMENT_ID to the deployment id to restore.'
      end

      DeploymentId.validate!(@options.deployment_id)
    end

    def confirm!
      return if @options.skip_confirm

      unless @input.tty?
        raise RollbackError, 'Non-interactive session: pass --yes to confirm rollback.'
      end

      @output.print('Proceed with rollback? [y/N] ')
      answer = @input.gets.to_s.strip.downcase
      raise RollbackError, 'Rollback cancelled.' unless answer == 'y'
    end
  end
end
