class AddCreatedAtIndexToFollows < ActiveRecord::Migration
  def change
    add_index :follows, :created_at
  end
end
