# frozen_string_literal: true

module PhotoFinder
  module QueryBuilder
    module_function

    def build(case_record)
      parts = []
      parts.concat(case_record.subjects.map(&:name))
      parts << case_record.city
      parts << case_record.state&.name
      parts.compact.map(&:strip).compact_blank.join(' ')
    end
  end
end
