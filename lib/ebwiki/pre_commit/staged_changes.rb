# frozen_string_literal: true

require 'fileutils'
require 'pathname'

module Ebwiki
  module PreCommit
    class StagedChanges
      RUBY_LIKE = /\.(rb|rake|gemspec|ru)\z/i
      RUBOCOP_SPECIAL = /\A(
        Gemfile|Rakefile|Guardfile|Capfile|Berksfile|Cheffile|Podfile|
        Thorfile|Vagabondfile|Vagrantfile
      )\z/x

      def initialize(repo_root:, git: GitCommand.new(repo_root: repo_root))
        @repo_root = Pathname.new(repo_root).expand_path
        @git = git
      end

      def entries
        @entries ||= @git.staged_name_status
      end

      def paths
        @paths ||= @git.staged_paths
      end

      def docs_only?
        return false if paths.empty?

        paths.all? { |path| docs_only_path?(path) }
      end

      def brakeman_needed?
        return false if paths.empty? || docs_only?

        paths.any? { |path| brakeman_trigger_path?(path) }
      end

      def rubocop_full_tree?
        paths.any? do |path|
          RUBOCOP_CONFIG_PATHS.include?(path) || LOCKFILE_PATHS.include?(path)
        end
      end

      def rubocop_ruby_paths
        return [] if docs_only?

        if rubocop_full_tree?
          project_rubocop_ruby_files
        else
          paths.select { |path| rubocop_candidate?(path) && !deleted?(path) }
        end
      end

      def skip_reason_for(check)
        return nil unless docs_only?

        "Only documentation paths are staged; skipping #{check}."
      end

      private

      def docs_only_path?(path)
        DOCS_ONLY_GLOBS.any? { |glob| File.fnmatch?(glob, path, File::FNM_PATHNAME | File::FNM_EXTGLOB) }
      end

      def brakeman_trigger_path?(path)
        BRAKEMAN_TRIGGER_GLOBS.any? do |glob|
          File.fnmatch?(glob, path, File::FNM_PATHNAME | File::FNM_EXTGLOB)
        end
      end

      def rubocop_candidate?(path)
        return true if path.match?(RUBY_LIKE)
        return true if RUBOCOP_SPECIAL.match?(File.basename(path))

        false
      end

      def deleted?(path)
        entries.any? { |entry| entry[:path] == path && entry[:status] == 'D' }
      end

      def project_rubocop_ruby_files
        tracked = @git.run!('ls-files', '-z').split("\0")
        tracked.select { |path| rubocop_candidate?(path) && File.file?(@repo_root.join(path)) }
      end
    end
  end
end
