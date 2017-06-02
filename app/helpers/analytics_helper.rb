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
  
  def recently_updated_cases
    html = ""
    
    Article.order(updated_at: :desc).first(10).each_with_index do |article, i|
     html += "<tr>" +
       "<td>#{ i + 1 }</td>" +
       "<td>#{ link_to truncate(article.title, length: 14), article }</td>" +
       "<td><small>#{ article.updated_at.strftime("%m.%e, %l:%M %p") }</small></td>" +
     "</tr>"
    end
    
    return raw(html)
  end
  
  def most_followed_cases
    html = ""
    
    Article.most_recent_by_follower(10).each_with_index do |article, i|
      html += "<tr>" +
          "<td>#{ i + 1 }</td>" +
          "<td>#{ link_to truncate(article.title, length: 25), article }</td>" +
          "<td>#{ link_to article.follows_count, articles_followers_path(article) }</td>" +
        "</tr>"
    end
    
    return raw(html)
  end
  
  def weekly_visitors_by_landing_page
    html = ""
    
    Visit.where(started_at: 7.days.ago..Time.now).group(:landing_page).collect{|v| v.find_by_slug(visit[0].split('/').last).present?}.order('count_id DESC').limit(13).count(:id).each_with_index do |visit, i| 
      html += "<tr>" +
        "<td>#{ i }</td>" +
          "<td>#{ link_to truncate(Article.find_by_slug(visit[0].split('/').last).title, length: 25), article_path(Article.find_by_slug(visit[0].split('/').last)) }</td>" +
          "<td>#{ visit[1] }</td>"
      "</tr>"
    end
    
    return raw(html)
  end
  
  def recent_comments_by_creation_time
    html = ""
    
    Comment.order(created_at: :desc).each do |comment| 
      return "<li> " +
        "<blockquote class='blockquote'> " +
          "<p>#{ link_to( truncate(Article.find(comment.commentable_id).title, length: 30), article_path(Article.find(comment.commentable_id)) ) } -- #{ comment.created_at.strftime("%B %d, %Y") }</p>" +
          "<p>#{ link_to( truncate(comment.content, length: 100), article_path(Article.find(comment.commentable_id))) }</p>" +
          "<small>#{ link_to(User.find(comment.user_id).name, user_path(User.find(comment.user_id))) }</small>" +
        "</blockquote>" +
      "</li>"
    end
    
    return raw(html)
  end
end
