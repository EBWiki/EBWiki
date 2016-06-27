class ArticleAgency < ActiveRecord::Base
  belongs_to :article
  belongs_to :agency
end
