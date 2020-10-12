# frozen_string_literal: true

# This service object, given a list of URLs and the views for each one, will
# return a list of cases the URLs lead to the corresponding views.
class DetermineVisitsToCases
  include Service

  def call(visit_info)
    cases = []
    visit_info.each do |(url, views)|
      this_case = Case.friendly.find(url.split('/').last)
      cases << [this_case, views]
    rescue ActiveRecord::RecordNotFound # rubocop:todo Lint/SuppressedException
    end
    cases
  end
end
