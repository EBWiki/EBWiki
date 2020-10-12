class AddJurisdictionColumnToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :jurisdiction, :jurisdiction, index: true
  end
end
