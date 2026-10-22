# frozen_string_literal: true

require 'open3'
require 'stringio'

module Ebwiki
  module PreCommit
    class RubocopRunner
      def initialize(repo_root:, git: GitCommand.new(repo_root: repo_root))
        @repo_root = repo_root
        @git = git
        @config_path = File.join(repo_root, '.rubocop.yml')
      end

      def run(staged:, logger: ->(*) {})
        reason = staged.skip_reason_for('RuboCop')
        if reason
          logger.call(:info, reason)
          return :skipped
        end

        paths = staged.rubocop_ruby_paths
        if paths.empty?
          logger.call(:info, 'No RuboCop-eligible Ruby paths staged.')
          return :skipped
        end

        require 'rubocop'
      rescue LoadError => e
        raise ToolMissingError.new(
          'RuboCop is not available. Run `bundle install` in the repo root.',
          instructions: e.message
        )
      else
        if staged.rubocop_full_tree?
          run_full_tree(logger, paths)
        else
          run_staged_stdin(logger, paths)
        end
      end

      private

      def run_full_tree(logger, paths)
        args = ['--format', 'simple', '--force-exclusion', '-c', @config_path] + paths
        success, output = capture_in_repo { RuboCop::CLI.new.run(args).zero? }
        fail_or_pass(logger, paths, success, output)
      end

      def run_staged_stdin(logger, paths)
        paths.each do |relative_path|
          content = @git.blob_at_index(relative_path)
          if content.nil?
            raise UserFacingError.new(
              "Cannot read staged content for #{relative_path}.",
              instructions: 'Stage the file again with `git add`, or commit from a clean index.'
            )
          end

          stdout, stderr, status = Open3.capture3(
            'bundle', 'exec', 'rubocop',
            '--format', 'simple',
            '--force-exclusion',
            '-c', @config_path,
            '--stdin', relative_path,
            stdin_data: content,
            chdir: @repo_root
          )
          success = status.success?
          output = stdout + stderr
          unless success
            fail_or_pass(logger, paths, false, output)
            return
          end
        end
        logger.call(:info, "RuboCop passed (#{paths.size} staged file(s)).")
        :passed
      end

      def fail_or_pass(logger, paths, success, output)
        unless success
          logger.call(:error, output)
          raise ToolFailedError.new(
            'RuboCop reported offenses on staged content.',
            instructions: output
          )
        end
        logger.call(:info, "RuboCop passed (#{paths.size} file(s)).")
        :passed
      end

      def capture_in_repo
        Dir.chdir(@repo_root) do
          stdout = StringIO.new
          real_stdout = $stdout
          stderr = StringIO.new
          real_stderr = $stderr
          ok = yield
          output = stdout.string + stderr.string
          [ok, output]
        ensure
          $stdout = real_stdout
          $stderr = real_stderr
        end
      end
    end
  end
end
