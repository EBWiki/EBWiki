# frozen_string_literal: true

require 'fileutils'
require 'shellwords'
require 'tmpdir'

module PreCommitGitRepo
  def with_pre_commit_repo(&block)
    Dir.mktmpdir('ebwiki-pre-commit-spec-') do |root|
      init_bare_repo(root)
      yield root
    end
  end

  def init_bare_repo(root)
    run_git(root, 'init')
    run_git(root, 'config', 'user.email', 'spec@example.com')
    run_git(root, 'config', 'user.name', 'Spec')
    write_file(root, '.rubocop.yml', <<~YAML)
      AllCops:
        DisabledByDefault: true
        TargetRubyVersion: 3.4
      Layout/SpaceAroundOperators:
        Enabled: true
      Style/FrozenStringLiteralComment:
        Enabled: true
    YAML
    write_file(root, 'config/brakeman.baseline.json', <<~JSON)
      {"approved_fingerprints": []}
    JSON
    write_file(root, 'README.md', "# test\n")
    run_git(root, 'add', '.')
    run_git(root, 'commit', '-m', 'initial')
  end

  def write_file(root, relative_path, content)
    path = File.join(root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def stage_file(root, relative_path, content)
    write_file(root, relative_path, content)
    run_git(root, 'add', relative_path)
  end

  def run_git(root, *args)
    system('git', *args, chdir: root) || raise("git #{args.join(' ')} failed")
  end

  def capture_git(root, *args)
    `cd #{Shellwords.escape(root)} && git #{args.join(' ')}`
  end
end

RSpec.configure do |config|
  config.include PreCommitGitRepo
end
