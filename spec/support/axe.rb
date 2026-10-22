# frozen_string_literal: true

require 'axe/dsl'

RSpec.configure do |config|
  config.include Axe::DSL, type: :feature
end

module MemorialPhotosAxeHelpers
  SERIOUS_IMPACTS = %i[serious critical].freeze

  def expect_no_serious_or_critical_axe_violations(page, context_selector: '.memorial-photos')
    run = Axe::API::Run.new.within(context_selector)
    audit = Axe::Core.new(page).call(run)
    serious_violations = audit.results.violations.select do |violation|
      SERIOUS_IMPACTS.include?(violation.impact)
    end

    return if serious_violations.empty?

    raise RSpec::Expectations::ExpectationNotMetError,
          "Axe serious or critical violations:\n#{format_axe_violations(serious_violations)}"
  end

  def format_axe_violations(violations)
    violations.map { |rule| "- #{rule.id}: #{rule.help} (#{rule.impact})" }.join("\n")
  end
end

RSpec.configure do |config|
  config.include MemorialPhotosAxeHelpers, type: :feature
end
