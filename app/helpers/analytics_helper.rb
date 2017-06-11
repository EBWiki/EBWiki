module AnalyticsHelper
  def visits_by_day(visits)
    visits.group_by_day(:started_at).count
  end
  
  def visits_today_by_browser(visits)
    visits.where(started_at: 1.days.ago..Time.now).group(:browser).count
  end

  def users_by_day(users)
    users.group_by_day(:created_at).count
  end
  
  def visits_today_by_referring_domain(visits)
    visits.where(started_at: 1.day.ago..Time.now).group(:referring_domain).count
  end
    
  def new_visits
    Visit.where(started_at: 7.days.ago..Time.now).group(:landing_page).order('count_id DESC').limit(13).count(:id)
  end
  
  def link_to_article_title(article, length)
    link_to truncate(article.title, length: length), article
  end
  
  def link_to_article_follower_count(article)
    link_to article.follows_count, articles_followers_path(article)
  end
  
  def article_updated_at(article)
    article.updated_at.strftime("%m.%e, %l:%M %p")
  end
  
  def recent_comments_by_creation_time
    if Comment.all.empty?
      return raw '<p>No comments yet.</p>'
    end
    
    Comment.order(created_at: :desc).each do |comment| 
      return raw ("<li> " +
        "<blockquote class='blockquote'> " +
          "<p>#{ link_to( truncate(Article.find(comment.commentable_id).title, length: 30), article_path(Article.find(comment.commentable_id)) ) } -- #{ comment.created_at.strftime("%B %d, %Y") }</p>" +
          "<p>#{ link_to( truncate(comment.content, length: 100), article_path(Article.find(comment.commentable_id))) }</p>" +
          "<small>#{ link_to(User.find(comment.user_id).name, user_path(User.find(comment.user_id))) }</small>" +
        "</blockquote>" +
      "</li>")
    end
  end
end
