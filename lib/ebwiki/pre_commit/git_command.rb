# frozen_string_literal: true

require 'open3'

module Ebwiki
  module PreCommit
    class GitCommand
      def initialize(repo_root:)
        @repo_root = repo_root
      end

      def run(*args, allow_failure: false)
        stdout, stderr, status = Open3.capture3(
          { 'GIT_TERMINAL_PROMPT' => '0' },
          'git', *args,
          chdir: @repo_root
        )
        return [stdout, stderr, status] if allow_failure || status.success?

        raise ToolFailedError.new(
          "git #{args.join(' ')} failed (exit #{status.exitstatus})",
          instructions: stderr.empty? ? stdout : stderr
        )
      end

      def run!(*)
        run(*).first
      end

      def staged_name_status
        out = run!('diff', '--cached', '--name-status', '-z')
        parse_name_status_z(out)
      end

      def staged_paths
        run!('diff', '--cached', '--name-only', '-z').split("\0").reject(&:empty?)
      end

      def blob_at_index(path)
        run!('show', ":#{path}")
      rescue ToolFailedError
        nil
      end

      private

      def parse_name_status_z(data)
        entries = []
        tokens = data.split("\0").reject(&:empty?)
        i = 0
        while i < tokens.length
          status = tokens[i]
          i += 1
          if status.start_with?('R', 'C')
            old_path = tokens[i]
            new_path = tokens[i + 1]
            i += 2
            entries << { status: status, path: new_path, old_path: old_path }
          else
            path = tokens[i]
            i += 1
            entries << { status: status, path: path }
          end
        end
        entries
      end
    end
  end
end
