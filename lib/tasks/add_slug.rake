# frozen_string_literal: true

desc 'Add slug to articles'
task add_slug: :environment do
  p 'Task started!'
  articles = Article.where(title: nil)
  articles.each do |article|
    next unless article.subjects.count.positive?
    article.update_attributes(
      title: article.subjects.first.name,
      slug: article.subjects.first.name.parameterize
    )
    article.save
    p "fixed article number #{article.id}"
  end
  p 'Done!'
end
