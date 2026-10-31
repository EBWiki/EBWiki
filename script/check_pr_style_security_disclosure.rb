#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open3'

repo_root = File.expand_path('..', __dir__)
$LOAD_PATH.unshift(File.join(repo_root, 'lib'))
require 'ebwiki/pull_request/style_security_disclosure'

base_ref = ENV.fetch('PR_BASE_SHA', ENV.fetch('GITHUB_BASE_REF', 'origin/main'))
body = ENV.fetch('PR_BODY', '')

changed, status = Open3.capture2('git', 'diff', '--name-only', "#{base_ref}...HEAD",
                                 chdir: repo_root)
unless status.success?
  warn "Could not diff against #{base_ref}"
  exit 1
end

files = changed.split("\n").map(&:strip).reject(&:empty?)
checker = Ebwiki::PullRequest::StyleSecurityDisclosure.new(body: body, changed_files: files)

if checker.required? && !checker.satisfied?
  warn checker.failure_message
  exit 1
end

puts 'Style/security disclosure check passed.'
