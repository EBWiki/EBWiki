class ChangeColumnName < ActiveRecord::Migration[5.2]
  def change
  	rename_column :agencies, :jurisdiction, :jurisdiction_type
  end
end
