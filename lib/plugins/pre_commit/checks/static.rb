# frozen_string_literal: true

require 'pre-commit/checks/plugin'
require 'pre-commit/error_list'
require 'ebwiki/pre_commit'

module PreCommit
  module Checks
    class Static < Plugin
      def self.description
        'Runs EBWiki staged RuboCop and Brakeman checks without booting Rails.'
      end

      def call(_staged_files)
        success = Ebwiki::PreCommit::Runner.new.call
        return if success

        PreCommit::ErrorList.new('EBWiki static pre-commit checks failed. See messages above.')
      end
    end
  end
end
