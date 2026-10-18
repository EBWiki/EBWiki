# frozen_string_literal: true

require_relative 'plain'
require_relative 'resource_name'
require_relative 'rollback_railway_validator'

module Release
  # Plans and optionally runs a Railway staging rollback.
  class Rollback
    Result = Data.define(:success, :message, :commands)

    def self.run(argv, executor: CommandExecutor.new, output: $stdout, error_output: $stderr,
                 input: $stdin)
      new(argv, executor: executor, output: output, error_output: error_output, input: input).run
    end

    def initialize(argv, executor:, output:, error_output: $stderr, input: $stdin)
      @argv = argv
      @executor = executor
      @output = output
      @error_output = error_output
      @input = input
    end

    def run
      @options = RollbackOptionsBuilder.from_argv(@argv)
      validate!
      commands = print_plan
      return dry_run_result(commands) if @options.dry_run

      finalize(execute!(commands))
    rescue RollbackError => e
      report_failure(e.message)
      Result.new(success: false, message: e.message, commands: [])
    end

    private

    def print_plan
      planner = Planner.new(@options, output: @output)
      commands = planner.commands
      planner.print(commands)
      commands
    end

    def finalize(result)
      report_failure(result.message) unless result.success
      result
    end

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

    def report_failure(message)
      return if Plain.blank?(message)

      @error_output.puts(message)
    end

    def validate!
      raise RollbackError, platform_help if Plain.blank?(@options.platform)

      case @options.platform
      when 'railway' then RollbackRailwayValidator.validate!(@options)
      else
        raise RollbackError, "Unsupported platform #{@options.platform.inspect}"
      end
    end

    def platform_help
      'Set RAILWAY_TOKEN (workspace or account token). Service defaults to ebwiki and ' \
        'environment to production; omit RAILWAY_ROLLBACK_DEPLOYMENT_ID to use the ' \
        'newest earlier deployment Railway can roll back to.'
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
