# frozen_string_literal: true

module StagingDatabaseScrub
  module ReportPrinter
    module_function

    def print_assertion_result(result)
      $stdout.puts "case_count=#{result.case_count}"
      if result.violations.empty?
        $stdout.puts 'All scrub checks passed (counts that must be zero are zero).'
        return
      end

      result.violations.each do |name, count|
        $stdout.puts "#{name}=#{count}"
      end
    end
  end
end
