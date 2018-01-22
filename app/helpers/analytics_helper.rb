# frozen_string_literal: true

module AnalyticsHelper

  def metric_grouped_by_day(data, metric)
    data.group_by_day(metric)
  end

  def metric_grouped_by_category(data, category)
    data.group(category)
  end

  def link_to_article_title(article, length)
    link_to truncate(article.title, length: length), article
  end

  def article_updated_at(article)
    article.updated_at.strftime("%m.%e, %l:%M %p")
  end

  def link_to_article_followers(article)
    link_to article.follows_count, articles_followers_path(article)
  end

  def comment_created_at(comment)
    comment.created_at.strftime("%B %d, %Y")
  end

  def link_to_comment(comment, length)
    link_to truncate(comment.content, length: length), comment.commentable
  end

  def link_to_comment_user(comment)
    link_to User.find(comment.user_id).name, user_path(User.find(comment.user_id))
  end
end
