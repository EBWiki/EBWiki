class AddSlugToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :name, :string
    add_column :agencies, :street_address, :string
    add_column :agencies, :city, :string
    add_column :agencies, :state_id, :integer
    add_column :agencies, :zipcode, :string
    add_column :agencies, :description, :text
    add_column :agencies, :telephone, :string
    add_column :agencies, :email, :string
    add_column :agencies, :website, :string
    add_column :agencies, :lead_officer, :string
    add_column :agencies, :slug, :string
    add_index :agencies, :slug
  end
end
