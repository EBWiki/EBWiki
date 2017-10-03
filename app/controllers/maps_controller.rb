class MapsController < ApplicationController
	def index
		articles = Split.redis.get('articles')
		if articles.nil?
			articles = Article.pluck(:id,
															:latitude,
															:longitude,
															:default_avatar_url,
															:title,
															:overview).to_json
			Split.redis.set('articles', articles)
		end
		@articles = JSON.load articles
	end
end
