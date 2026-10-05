# frozen_string_literal: true

# Helper for case pages.
module CasesHelper
  def link_to_case_title(this_case, length)
    link_to truncate(this_case.title, length: length), this_case
  end
end
