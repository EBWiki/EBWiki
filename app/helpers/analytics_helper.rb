# frozen_string_literal: true

module AnalyticsHelper
  def metric_by_day(data, metric)
    case metric
    when :visits
      data.group_by_day(:started_at).count
    when :users
      data.group_by_day(:created_at).count
    end
  end

  def metric_grouped_by_category(data, category)
    data.group(category).count
  end

  def metric_grouped_by_category_in_descending_order(data, category, limit)
    data.group(category).order('count_id DESC').limit(limit).count(:id)
  end

  def link_to_article_title(article, length)
    link_to truncate(aricle.title, length: length), article
  end

  def link_to_article_follower_count(article)
    link_to article.follows_count, articles_followers_path(article)
  end

  def article_updated_at(article)
    article.updated_at.strftime("%m.%e, %l:%M %p")
  end
  
end
