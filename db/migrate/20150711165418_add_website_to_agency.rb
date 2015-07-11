class AddWebsiteToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :website, :string
  end
end
