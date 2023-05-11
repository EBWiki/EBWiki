class AddCreatedAtIndexToFollows < ActiveRecord::Migration[5.2]
  def change
    add_index :follows, :created_at
  end
end
