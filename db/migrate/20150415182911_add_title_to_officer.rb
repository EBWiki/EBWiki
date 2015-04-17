class AddTitleToOfficer < ActiveRecord::Migration
  def change
    add_column :officers, :title, :string
  end
end
