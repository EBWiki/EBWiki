class AddAdminIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :admin
  end
end
