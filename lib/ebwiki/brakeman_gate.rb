# frozen_string_literal: true

require_relative 'pre_commit'

module Ebwiki
  module BrakemanGate
    module_function

    def verify_repo!(repo_root: Dir.pwd)
      PreCommit::BrakemanRunner.new(repo_root: repo_root).run_full_repo!
    end
  end
end
