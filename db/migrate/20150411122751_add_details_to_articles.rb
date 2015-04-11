class AddDetailsToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :date, :date
    add_column :articles, :state_id, :integer
    add_column :articles, :city, :string
    add_column :articles, :address, :string
    add_column :articles, :zipcode, :string
    add_column :articles, :longitude, :float
    add_column :articles, :latitude, :float
    add_column :articles, :avatar, :string
  end
end
