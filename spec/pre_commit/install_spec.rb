# frozen_string_literal: true

require 'fileutils'
require_relative '../pre_commit_spec_helper'

RSpec.describe 'script/install-pre-commit' do
  it 'installs twice without error and preserves foreign hooks' do
    with_pre_commit_repo do |root|
      workspace = Pathname.new(File.expand_path('../..', __dir__))
      FileUtils.cp_r(workspace.join('lib'), File.join(root, 'lib'))
      FileUtils.mkdir_p(File.join(root, 'bin'))
      FileUtils.cp(workspace.join('bin/ebwiki-pre-commit'), File.join(root, 'bin/ebwiki-pre-commit'))
      FileUtils.mkdir_p(File.join(root, 'script'))
      FileUtils.cp(workspace.join('script/install-pre-commit'), File.join(root, 'script/install-pre-commit'))
      FileUtils.chmod(0o755, File.join(root, 'bin/ebwiki-pre-commit'))
      FileUtils.chmod(0o755, File.join(root, 'script/install-pre-commit'))
      install = File.join(root, 'script/install-pre-commit')
      hook = File.join(root, '.git/hooks/pre-commit')
      expect(system('bash', install, chdir: root)).to be(true)
      first = File.read(hook)
      expect(system('bash', install, chdir: root)).to be(true)
      expect(File.read(hook)).to eq(first)

      File.write(hook, "#!/bin/sh\n/custom/\n")
      expect(system('bash', install, chdir: root)).to be(true)
      expect(File.read(hook)).to include('/custom/')
    end
  end
end
