# frozen_string_literal: true

# Helper for analytics section of the site.
module AnalyticsHelper
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
end
