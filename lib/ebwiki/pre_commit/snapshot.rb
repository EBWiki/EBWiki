# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

module Ebwiki
  module PreCommit
    class Snapshot
      RENAME_OR_COPY_STATUSES = %w[R C].freeze

      def initialize(repo_root:, git: GitCommand.new(repo_root: repo_root))
        @repo_root = repo_root
        @git = git
      end

      # Builds a directory tree matching the staged commit: HEAD plus staged index changes.
      def with_staged_app
        Dir.mktmpdir('ebwiki-pre-commit-') do |root|
          populate_from_head(root)
          apply_staged_overlays(root)
          yield root
        end
      end

      # Writes staged blob content for RuboCop paths under a temp tree (no working tree reads).
      def with_staged_rubocop_files(paths)
        Dir.mktmpdir('ebwiki-rubocop-') do |root|
          paths.each do |relative_path|
            content = @git.blob_at_index(relative_path)
            next if content.nil?

            target = File.join(root, relative_path)
            FileUtils.mkdir_p(File.dirname(target))
            File.write(target, content)
          end
          yield root, paths.map { |p| File.join(root, p) }
        end
      end

      private

      def populate_from_head(root)
        archive = @git.run!('archive', 'HEAD')
        IO.popen(['tar', '-x', '-C', root], 'wb') { |io| io.write(archive) }
      end

      def apply_staged_overlays(root)
        @git.staged_name_status.each { |entry| apply_staged_overlay(root, entry) }
      end

      def apply_staged_overlay(root, entry)
        case entry[:status][0]
        when 'D'
          FileUtils.rm_f(File.join(root, entry[:path]))
        else
          remove_renamed_source(root, entry)
          write_index_blob(root, entry[:path])
        end
      end

      def remove_renamed_source(root, entry)
        return unless RENAME_OR_COPY_STATUSES.include?(entry[:status][0]) && entry[:old_path]

        FileUtils.rm_f(File.join(root, entry[:old_path]))
      end

      def write_index_blob(root, path)
        content = @git.blob_at_index(path)
        return if content.nil?

        target = File.join(root, path)
        FileUtils.mkdir_p(File.dirname(target))
        File.write(target, content)
      end
    end
  end
end
