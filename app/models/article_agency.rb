# frozen_string_literal: true

class ArticleAgency < ActiveRecord::Base
  belongs_to :article
  belongs_to :agency
end
