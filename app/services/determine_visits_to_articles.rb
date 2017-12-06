class DetermineVisitsToArticles
  include Service

  def call(visits)
    articles = []
    visits.each do |visits_info|
      url = visits_info[0]
      views = visits_info[1]
      article = Article.friendly.find(url.split('/').last)
      articles << [article, views] if article.exists?
    end
    articles
  end
end
