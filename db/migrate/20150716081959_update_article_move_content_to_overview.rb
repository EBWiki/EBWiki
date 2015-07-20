class UpdateArticleMoveContentToOverview < ActiveRecord::Migration
  reversible do |dir|
  	dir.up do
	  	Article.where.not(content:nil).each do |article|
	  		article.overview = article.content
	  		article.content = ""
	  		article.save!
	  	end
  		remove_column :articles, :content
  	end

  	dir.down do
  		add_column :articles, :content
  	end
  end
end
