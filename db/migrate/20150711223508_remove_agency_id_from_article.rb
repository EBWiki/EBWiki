class RemoveAgencyIdFromArticle < ActiveRecord::Migration
  def change
  	remove_column :articles, :agency_id
  end
end
