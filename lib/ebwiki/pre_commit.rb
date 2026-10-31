# frozen_string_literal: true

require_relative 'pre_commit/errors'
require_relative 'pre_commit/git_command'
require_relative 'pre_commit/staged_changes'
require_relative 'pre_commit/snapshot'
require_relative 'pre_commit/rubocop_runner'
require_relative 'pre_commit/brakeman_baseline'
require_relative 'pre_commit/brakeman_runner'
require_relative 'pre_commit/runner'
require_relative 'pre_commit/cli'

module Ebwiki
  module PreCommit
    RUBOCOP_CONFIG_PATHS = %w[
      .rubocop.yml
      .rubocop.yaml
      .rubocop_todo.yml
    ].freeze

    LOCKFILE_PATHS = %w[Gemfile Gemfile.lock].freeze

    # Files whose staged changes require a Brakeman scan of a full app snapshot.
    BRAKEMAN_TRIGGER_GLOBS = [
      'app/**/*.rb',
      'config/**/*.rb',
      'config/routes.rb',
      'lib/**/*.rb',
      'db/migrate/**/*.rb',
      'Gemfile',
      'Gemfile.lock',
      'config/brakeman.ignore',
      'config/brakeman.baseline.json'
    ].freeze

    DOCS_ONLY_GLOBS = [
      'docs/**',
      '**/*.md',
      'LICENSE',
      'COPYING'
    ].freeze

    UNSUPPORTED_STYLE_PATHS = [
      'JavaScript/TypeScript (no ESLint script in package.json)',
      'CSS/SCSS (legacy CSSLint config only; not installed)',
      'CoffeeScript, Slim, ERB templates (not covered by RuboCop in this hook)'
    ].freeze
  end
end
