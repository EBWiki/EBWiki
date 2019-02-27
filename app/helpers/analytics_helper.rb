# frozen_string_literal: true

# Helper for analytics section of the site.
module AnalyticsHelper
  def metric_grouped_by_day(data, metric)
    data.group_by_day(metric)
  end

  def metric_grouped_by_category(data, category)
    data.group(category)
  end

  def link_to_case_followers(this_case)
    link_to this_case.follows_count, cases_followers_path(this_case)
  end

  def comment_created_at(comment)
    comment.created_at.strftime('%B %d, %Y')
  end

  def link_to_comment(comment, length)
    link_to truncate(comment.content, length: length), comment.commentable
  end

  def link_to_comment_user(comment)
    link_to User.find(comment.user_id).name, user_path(User.find(comment.user_id))
  end

  def case_updates
    # returns all versions of all cases created in the last 30 days
    PaperTrail::Version.where('created_at > ?', 30.days.ago)
  end

  def case_updaters_count(how_many)
    # returns list of uniq editors of case updates along woth thenumber of updates each has authored
    case_updates.group(:whodunnit).order('count_id DESC').limit(how_many).count(:id)
  end
end
