class DetermineVisitsToArticles
  include Service

  # The begin..rescue..end block is used to determine if the URL leads to an
  # article without performing the same query twice (to check if the article
  # exists and then retrieve the article object.  Once Ruby is upgraded to
  # >= 2.5, the rescue can be performed directly within the each do..end block.
  def call(visit_info)
    articles = []
    visit_info.each do |(url, views)|
      begin
        article = Article.friendly.find(url.split('/').last)
        articles << [article, views]
      rescue ActiveRecord::RecordNotFound
      end
    end
    articles
  end
end
