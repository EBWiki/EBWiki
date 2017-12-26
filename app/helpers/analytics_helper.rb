# frozen_string_literal: true

module AnalyticsHelper
  def case_updates
    # returns all versions of all cases created in the last 30 days
    PaperTrail::Version.where('created_at > ?', 30.days.ago)
  end

  def case_updaters_count(how_many)
    # returns list of uniq editors of case updates along woth thenumber of updates each has authored
    case_updates.group(:whodunnit).order('count_id DESC').limit(how_many).count(:id)
  end
end