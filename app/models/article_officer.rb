class ArticleOfficer < ActiveRecord::Base
	belongs_to :officer
	belongs_to :article
end
