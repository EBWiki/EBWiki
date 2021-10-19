class RemoveUserIdFromCases < ActiveRecord::Migration[5.2]
  def change
    remove_column :cases, :user_id, :integer
  end
end
