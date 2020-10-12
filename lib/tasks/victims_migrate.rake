# frozen_string_literal: true

desc 'Create Agencies from csv'
task victims_migrate: :environment do
  p 'Task started!'

  Article.find_each do |article|
    subject = Subject.new(
      article_id: article.id,
      name: article.title,
      age: article.age
    )
    subject.save
    p 'Created!'
  end
  p 'Done!'
end
