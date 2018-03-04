# frozen_string_literal: true

module AnalyticsHelper
  def metric_grouped_by_day(data, metric)
    data.group_by_day(metric)
  end

  def metric_grouped_by_category(data, category)
    data.group(category)
  end

  def link_to_case_title(this_case, length)
    link_to truncate(this_case.title, length: length), this_case
  end

  def link_to_case_followers(this_case)
    link_to this_case.follows_count, cases_followers_path(this_case)
  end

  def comment_created_at(comment)
    comment.created_at.strftime('Y')
  end

  def link_to_comment(comment, length)
    link_to truncate(comment.content, length: length), comment.commentable
  end

  def link_to_comment_user(comment)
    link_to User.find(comment.user_id).name, user_path(User.find(comment.user_id))
  end
end
