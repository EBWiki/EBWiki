class RemoveJurisdictionTypeFromAgencies < ActiveRecord::Migration
  def change
    remove_column :agencies, :jurisdiction_type, :string
  end
end
