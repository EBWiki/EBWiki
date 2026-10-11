# frozen_string_literal: true

# Builds the ordered list of PaperTrail versions shown on a case history page.
module CaseHistory
  module_function

  def versions_for(case_record)
    case_record.versions.order(created_at: :desc).to_a.uniq { |version| dedupe_key(version) }
  end

  def dedupe_key(version)
    [
      version.created_at.to_i,
      version.event,
      version.whodunnit.to_s,
      version.comment.to_s
    ]
  end
end
