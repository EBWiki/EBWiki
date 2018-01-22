require 'rails_helper'

describe DetermineVisitsToArticles do

  it 'returns visits to cases' do
    article = FactoryBot.create(:article)
    slug_name = article.friendly_id
    article_URL = 'https://ebwiki.org/articles/' + slug_name

    visit_info = [['https://blackopswiki.herokuapp.com/', 1],
                  [article_URL, 3]]

    articles = DetermineVisitsToArticles.call(visit_info)
    expect(articles).to eq([[article, 3]])
  end

end