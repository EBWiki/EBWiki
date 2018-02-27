# frozen_string_literal: true

# This service object, given a list of URLs and the views for each one, will
# return a list of cases the URLs lead to the corresponding views.
class DetermineVisitsToCases
  include Service

  # The begin..rescue..end block is used to determine if the URL leads to an
  # article without performing the same query twice (to check if the case
  # exists and then retrieve the case object.  Once Ruby is upgraded to
  # >= 2.5, the rescue can be performed directly within the each do..end block.
  def call(visit_info)
    cases = []
    visit_info.each do |(url, views)|
      begin
        this_case = Case.friendly.find(url.split('/').last)
        cases << [this_case, views]
      rescue ActiveRecord::RecordNotFound
      end
    end
    cases
  end
end
