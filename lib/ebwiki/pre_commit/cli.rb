# frozen_string_literal: true

module Ebwiki
  module PreCommit
    class Cli
      def self.run_static!(repo_root: Dir.pwd)
        success = Runner.new(repo_root: repo_root).call
        exit(1) unless success
      end

      def self.run_full!(repo_root: Dir.pwd)
        run_static!(repo_root: repo_root)
        system('bundle', 'exec', 'rspec', 'spec/', chdir: repo_root) || exit(1)
      end
    end
  end
end
