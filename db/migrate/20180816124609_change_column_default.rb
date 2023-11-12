class ChangeColumnDefault < ActiveRecord::Migration[5.2]
  def up
  	change_column_default :agencies, :jurisdiction, 'none'
  end

end
