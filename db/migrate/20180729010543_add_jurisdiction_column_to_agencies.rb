class AddJurisdictionColumnToAgencies < ActiveRecord::Migration[5.2]
  def change
    add_column :agencies, :jurisdiction, :jurisdiction, index: true
  end
end
