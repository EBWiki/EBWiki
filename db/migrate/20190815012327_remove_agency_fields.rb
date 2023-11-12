class RemoveAgencyFields < ActiveRecord::Migration[5.2][5.0]
  def change
    remove_column :agencies, :description, :text
    remove_column :agencies, :lead_officer, :string
  end
end
