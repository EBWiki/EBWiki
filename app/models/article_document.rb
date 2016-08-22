class ArticleDocument < ActiveRecord::Base
  belongs_to :article
  belongs_to :document
end
