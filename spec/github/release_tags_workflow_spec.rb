# frozen_string_literal: true

require 'rails_helper'
require 'open3'
require 'tmpdir'
require 'yaml'

RSpec.describe 'Release tags workflow' do
  let(:workflow) { YAML.safe_load(File.read(Rails.root.join('.github/workflows/release-tags.yml')), aliases: true) }
  let(:guard_command) { './scripts/github-require-protected-environment.sh release-tags' }
  let(:pre_pgsearch_sha) { '912745b257dbc9fdd5c48b9cf563df0905375c86' }
  let(:main_only) { "github.ref == 'refs/heads/main'" }

  def contract_satisfied?(doc)
    triggers = doc['on'] || doc[true]
    return false unless triggers.is_a?(Hash) && triggers.keys == ['workflow_dispatch']
    return false unless doc.dig('permissions', 'contents') == 'read'

    guard = doc.dig('jobs', 'require_environment')
    tag = doc.dig('jobs', 'tag')
    return false unless guard.is_a?(Hash) && tag.is_a?(Hash)
    return false unless guard['environment'].nil? && guard['if'] == main_only
    return false unless guard.fetch('steps', []).any? { |step| step['run'].to_s.strip == guard_command }

    tag['environment'] == 'release-tags' && tag['if'] == main_only &&
      Array(tag['needs']).include?('require_environment') &&
      tag.dig('permissions', 'contents') == 'write' &&
      no_inline_inputs?(doc)
  end

  # Inputs reach the shell only through env, never through ${{ }} inside run.
  def no_inline_inputs?(doc)
    doc.fetch('jobs').values.flat_map { |job| job.fetch('steps', []) }.none? do |step|
      step['run'].to_s.include?('${{')
    end
  end

  def step_script(name)
    workflow.dig('jobs', 'tag', 'steps').find { |entry| entry['name'] == name }.fetch('run')
  end

  def run_step(name, env, chdir: Dir.pwd)
    Open3.capture3(env.merge('PATH' => ENV.fetch('PATH')), 'bash', '-e', '-c', step_script(name),
                   unsetenv_others: true, chdir: chdir)
  end

  def run_resolve(env)
    Dir.mktmpdir do |dir|
      output = File.join(dir, 'output')
      File.write(output, '')
      _out, err, status = run_step('Resolve tag target', env.merge('GITHUB_OUTPUT' => output))
      [File.read(output), err, status]
    end
  end

  def git(dir, *args)
    out, err, status = Open3.capture3(GIT_ENV, 'git', *args, chdir: dir)
    raise "git #{args.join(' ')} failed: #{err}" unless status.success?

    out.strip
  end

  GIT_ENV = {
    'GIT_AUTHOR_NAME' => 'Spec', 'GIT_AUTHOR_EMAIL' => 'spec@example.com',
    'GIT_COMMITTER_NAME' => 'Spec', 'GIT_COMMITTER_EMAIL' => 'spec@example.com',
    'GIT_CONFIG_NOSYSTEM' => '1', 'GIT_CONFIG_GLOBAL' => File::NULL
  }.freeze

  # A clone whose origin has one commit on main, plus a local commit that is not on main.
  def with_clone
    Dir.mktmpdir do |dir|
      origin = File.join(dir, 'origin.git')
      clone = File.join(dir, 'clone')
      git(dir, 'init', '--quiet', '--bare', '--initial-branch=main', origin)
      git(dir, 'clone', '--quiet', origin, clone)
      git(clone, 'commit', '--quiet', '--allow-empty', '-m', 'on main')
      git(clone, 'push', '--quiet', 'origin', 'HEAD:main')
      on_main = git(clone, 'rev-parse', 'HEAD')
      git(clone, 'commit', '--quiet', '--allow-empty', '-m', 'not on main')
      yield clone, on_main, git(clone, 'rev-parse', 'HEAD')
    end
  end

  def run_target_check(clone, tag, sha)
    run_step('Require the commit on main and the tag to be new', GIT_ENV.merge('TAG' => tag, 'SHA' => sha),
             chdir: clone)
  end

  it 'satisfies the release tags contract' do
    expect(contract_satisfied?(workflow)).to be(true)
  end

  it 'tags pre-pgsearch at the full 912745b2 SHA' do
    output, err, status = run_resolve('TAG_KIND' => 'v2026.10.18-pre-pgsearch', 'COMMIT' => '')
    expect(status.success?).to be(true), err
    expect(output).to eq("sha=#{pre_pgsearch_sha}\n")
  end

  it 'tags the post-merge release at the given full SHA' do
    sha = 'a' * 40
    output, err, status = run_resolve('TAG_KIND' => 'v2026.10.18-1', 'COMMIT' => sha)
    expect(status.success?).to be(true), err
    expect(output).to eq("sha=#{sha}\n")
  end

  {
    'a missing commit' => '',
    'a short SHA' => '912745b2',
    'an uppercase SHA' => 'A' * 40,
    'a shell injection' => "#{'a' * 40}; echo pwned"
  }.each do |label, commit|
    it "refuses the post-merge tag with #{label}" do
      output, _err, status = run_resolve('TAG_KIND' => 'v2026.10.18-1', 'COMMIT' => commit)
      expect(status.success?).to be(false)
      expect(output).to eq('')
    end
  end

  it 'accepts a commit on main with a new tag' do
    with_clone do |clone, on_main, _off_main|
      _out, err, status = run_target_check(clone, 'v2026.10.18-1', on_main)
      expect(status.success?).to be(true), err
    end
  end

  it 'refuses a commit that is not on main' do
    with_clone do |clone, _on_main, off_main|
      _out, _err, status = run_target_check(clone, 'v2026.10.18-1', off_main)
      expect(status.success?).to be(false)
    end
  end

  it 'refuses a tag that already exists' do
    with_clone do |clone, on_main, _off_main|
      git(clone, 'tag', 'v2026.10.18-1', on_main)
      git(clone, 'push', '--quiet', 'origin', 'refs/tags/v2026.10.18-1')
      _out, err, status = run_target_check(clone, 'v2026.10.18-1', on_main)
      expect(status.success?).to be(false)
      expect(err).to include('release_tag_exists')
    end
  end

  it 'refuses an unknown tag kind' do
    _output, err, status = run_resolve('TAG_KIND' => 'v9.9.9', 'COMMIT' => 'a' * 40)
    expect(status.success?).to be(false)
    expect(err).to include('release_tag_input')
  end

  {
    'push trigger' => ->(doc) { (doc['on'] || doc[true])['push'] = { 'branches' => ['main'] } },
    'environment check job' => ->(doc) { doc['jobs'].delete('require_environment') },
    'tag job dependency' => ->(doc) { doc.dig('jobs', 'tag').delete('needs') },
    'release-tags environment' => ->(doc) { doc.dig('jobs', 'tag').delete('environment') },
    'environment check outside the environment' => lambda { |doc|
      doc.dig('jobs', 'require_environment')['environment'] = 'release-tags'
    },
    'main ref gate on the tag job' => ->(doc) { doc.dig('jobs', 'tag')['if'] = 'true' },
    'read-only default permissions' => ->(doc) { doc['permissions'] = { 'contents' => 'write' } },
    'inputs passed through env' => lambda { |doc|
      doc.dig('jobs', 'tag', 'steps').last['run'] = 'git tag "${{ inputs.tag_kind }}"'
    }
  }.each do |label, mutation|
    it "fails the contract without the #{label}" do
      mutated = YAML.safe_load(YAML.dump(workflow), aliases: true)
      mutation.call(mutated)
      expect(contract_satisfied?(mutated)).to be(false)
    end
  end
end
