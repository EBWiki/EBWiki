class AddDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :description, :text
    add_column :users, :state_id, :integer
    add_column :users, :state, :string
    add_column :users, :city, :string
    add_column :users, :facebook_url, :string
    add_column :users, :twitter_url, :string
    add_column :users, :linkedin, :string
  end
end
