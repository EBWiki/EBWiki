# frozen_string_literal: true

module Ebwiki
  module PreCommit
    class Runner
      def initialize(repo_root: Dir.pwd, logger: method(:default_logger))
        @repo_root = File.expand_path(repo_root)
        @logger = logger
        @git = GitCommand.new(repo_root: @repo_root)
      end

      def call
        staged = StagedChanges.new(repo_root: @repo_root, git: @git)
        if staged.empty?
          @logger.call(:info, 'No staged changes; static checks skipped.')
          return true
        end

        RubocopRunner.new(repo_root: @repo_root, git: @git).run(staged: staged, logger: @logger)
        BrakemanRunner.new(repo_root: @repo_root, git: @git).run(staged: staged, logger: @logger)
        true
      rescue UserFacingError => e
        @logger.call(:error, e.message)
        @logger.call(:error, e.instructions) if e.instructions
        false
      end

      private

      def default_logger(level, message)
        stream = level == :error ? $stderr : $stdout
        stream.puts("[pre-commit] #{message}")
      end
    end
  end
end
