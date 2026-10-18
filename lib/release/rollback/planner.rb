# frozen_string_literal: true

module Release
  class Rollback
    # Builds rollback shell commands and prints the operator plan.
    class Planner
      def initialize(options, output:)
        @options = options
        @output = output
      end

      def commands
        list = []
        list.concat(migration_commands) if @options.with_migration_down
        list << platform_command
        list
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

      def migration_commands
        case @options.platform
        when 'heroku'
          ["heroku run rake db:rollback STEP=1 -a #{@options.app_name}"]
        when 'railway'
          ['railway run bundle exec rails db:rollback STEP=1']
        else
          []
        end
      end

      def platform_command
        case @options.platform
        when 'heroku'
          "heroku releases:rollback -a #{@options.app_name}"
        when 'railway'
          deployment = @options.deployment_id
          service = @options.service_name
          "railway redeploy --deployment #{deployment} --service #{service}"
        end
      end

      def migration_note
        '  Migration note: PR #4410 does not add migrations. The cases.tsv column is additive; ' \
          'rollback is redeploy-only unless you pass --with-migration-down.'
      end
    end
  end
end
