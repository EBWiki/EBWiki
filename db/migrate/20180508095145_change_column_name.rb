class ChangeColumnName < ActiveRecord::Migration
  def change
  	rename_column :agencies, :jurisdiction, :jurisdiction_type
  end
end
