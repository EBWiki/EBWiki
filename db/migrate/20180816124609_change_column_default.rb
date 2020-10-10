class ChangeColumnDefault < ActiveRecord::Migration
  def up
  	change_column_default :agencies, :jurisdiction, 'none'
  end
  
end
