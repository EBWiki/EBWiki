class AddAdminIndexToUsers < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :admin
  end
end
