# frozen_string_literal: true

require 'open3'

module Ebwiki
  module PreCommit
    class RubocopRunner
      def initialize(repo_root:, git: GitCommand.new(repo_root: repo_root))
        @repo_root = repo_root
        @git = git
        @config_path = File.join(repo_root, '.rubocop.yml')
      end

      def run(staged:, logger: ->(*) {})
        return skip(logger, staged.skip_reason_for('RuboCop')) if staged.skip_reason_for('RuboCop')

        paths = staged.rubocop_ruby_paths
        return skip(logger, 'No RuboCop-eligible Ruby paths staged.') if paths.empty?

        require 'rubocop'
        staged.rubocop_full_tree? ? run_full_tree(logger, paths) : run_staged_stdin(logger, paths)
      rescue LoadError => e
        raise ToolMissingError.new(
          'RuboCop is not available. Run `bundle install` in the repo root.',
          instructions: e.message
        )
      end

      private

      def skip(logger, message)
        logger.call(:info, message)
        :skipped
      end

      def run_full_tree(logger, paths)
        args = ['--format', 'simple', '--force-exclusion', '-c', @config_path] + paths
        stdout, stderr, status = Open3.capture3('bundle', 'exec', 'rubocop', *args,
                                                chdir: @repo_root)
        report_result(logger, paths, status.success?, stdout + stderr) || :passed
      end

      def run_staged_stdin(logger, paths)
        paths.each do |relative_path|
          content = staged_content(relative_path)
          output, success = rubocop_stdin(relative_path, content)
          report_result(logger, paths, success, output) unless success
          break unless success
        end
        logger.call(:info, "RuboCop passed (#{paths.size} staged file(s)).")
        :passed
      end

      def staged_content(relative_path)
        @git.blob_at_index(relative_path) || raise(
          UserFacingError.new(
            "Cannot read staged content for #{relative_path}.",
            instructions: 'Stage the file again with `git add`, or commit from a clean index.'
          )
        )
      end

      def rubocop_stdin(relative_path, content)
        stdout, stderr, status = Open3.capture3(
          'bundle', 'exec', 'rubocop',
          '--format', 'simple', '--force-exclusion', '-c', @config_path, '--stdin', relative_path,
          stdin_data: content,
          chdir: @repo_root
        )
        [stdout + stderr, status.success?]
      end

      def report_result(logger, paths, success, output)
        return logger.call(:info, "RuboCop passed (#{paths.size} file(s)).") || :passed if success

        logger.call(:error, output)
        raise ToolFailedError.new('RuboCop reported offenses on staged content.',
                                  instructions: output)
      end
    end
  end
end
