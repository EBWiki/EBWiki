class MapsController < ApplicationController
	def index
		@articles = Article.all
	end
end
