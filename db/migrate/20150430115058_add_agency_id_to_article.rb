class AddAgencyIdToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :agency_id, :integer
  end
end
