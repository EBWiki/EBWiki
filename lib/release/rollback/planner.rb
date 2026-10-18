# frozen_string_literal: true

module Release
  class Rollback
    # Builds rollback commands and prints the rollback plan.
    class Planner
      def initialize(options, output:)
        @options = options
        @output = output
      end

      def commands
        case @options.platform
        when 'heroku' then [heroku_command]
        when 'railway' then [railway_command]
        else
          []
        end
      end

      def print(commands)
        @output.puts 'Release rollback plan:'
        @output.puts "  Platform: #{@options.platform}"
        mode = @options.dry_run ? '  Mode: dry run (no commands executed)' : '  Mode: execute'
        @output.puts(mode)
        @output.puts migration_note
        commands.each_with_index do |command, index|
          @output.puts "  #{index + 1}. #{command}"
        end
      end

      private

      def heroku_command
        app = ResourceName.validate!(@options.app_name, label: 'Heroku app name')
        ShellCommand.new(
          argv: ['heroku', 'releases:rollback', '-a', app],
          description: "heroku releases:rollback -a #{app}"
        )
      end

      def railway_command
        RailwayRollbackCommand.new(
          deployment_id: @options.deployment_id,
          service_name: @options.service_name,
          environment_slug: @options.environment_slug,
          description: railway_description
        )
      end

      def railway_description
        "Railway GraphQL deploymentRollback for deployment #{@options.deployment_id} " \
          "(service #{@options.service_name}, environment #{@options.environment_slug})"
      end

      def migration_note
        '  Migration note: rollback redeploys prior application code only. ' \
          'Do not run db:rollback for the cases.tsv column; it would break search.'
      end
    end
  end
end
