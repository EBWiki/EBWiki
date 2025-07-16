class RemoveJurisdictionTypeFromAgencies < ActiveRecord::Migration[5.2]
  def change
    remove_column :agencies, :jurisdiction_type, :string
  end
end
