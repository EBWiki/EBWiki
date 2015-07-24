class AddAubscribedToUser < ActiveRecord::Migration
  def change
  	unless User.column_names.include?("subscribed")
	    add_column :users, :subscribed, :boolean
	  end
  end
end
