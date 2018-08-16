class ChangeColumnDefault < ActiveRecord::Migration
  def change
  	change_column_default :agencies, :jurisdiction_type, 'none'
  end
end
