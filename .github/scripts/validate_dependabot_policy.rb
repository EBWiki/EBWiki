#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

path = File.expand_path('../dependabot.yml', __dir__)
config = YAML.safe_load(File.read(path), aliases: true)

errors = []

unless config.is_a?(Hash)
  abort('dependabot.yml must parse to a mapping')
end

errors << 'version must be 2' unless config['version'] == 2

updates = config['updates']
unless updates.is_a?(Array)
  abort('updates must be a list')
end

expected_ecosystems = %w[bundler npm github-actions]
updates_by_ecosystem = updates.each_with_object({}) { |entry, memo| memo[entry['package-ecosystem']] = entry }

missing = expected_ecosystems - updates_by_ecosystem.keys
extra = updates_by_ecosystem.keys - expected_ecosystems
errors << "missing ecosystems: #{missing.join(', ')}" if missing.any?
errors << "unexpected ecosystems: #{extra.join(', ')}" if extra.any?

expected_ecosystems.each do |ecosystem|
  entry = updates_by_ecosystem[ecosystem]
  next if entry.nil?

  limit = entry['open-pull-requests-limit']
  unless limit.is_a?(Integer) && limit.positive? && limit <= 5
    errors << "#{ecosystem}: open-pull-requests-limit must be an integer between 1 and 5"
  end

  ignores = entry['ignore']
  has_semver_major_ignore = ignores.is_a?(Array) && ignores.any? do |ignore_entry|
    next false unless ignore_entry.is_a?(Hash)

    ignore_entry['dependency-name'] == '*' &&
      Array(ignore_entry['update-types']).include?('version-update:semver-major')
  end
  errors << "#{ecosystem}: must ignore semver-major updates for '*'" unless has_semver_major_ignore

  groups = entry['groups']
  unless groups.is_a?(Hash) && groups.any?
    errors << "#{ecosystem}: groups must be present"
    next
  end

  security_group_present = groups.values.any? do |group|
    group.is_a?(Hash) && group['applies-to'] == 'security-updates'
  end
  errors << "#{ecosystem}: must define a security-updates group" unless security_group_present

  non_security_groups = groups.values.select do |group|
    group.is_a?(Hash) && group['applies-to'] != 'security-updates'
  end

  non_security_groups.each do |group|
    update_types = Array(group['update-types'])
    next if update_types.empty?

    unless update_types.all? { |type| %w[patch minor].include?(type) }
      errors << "#{ecosystem}: non-security groups can only use patch/minor update-types"
    end
  end
end

if errors.any?
  warn 'Dependabot policy validation failed:'
  errors.each { |error| warn "- #{error}" }
  exit 1
end

puts 'Dependabot policy validation passed'
