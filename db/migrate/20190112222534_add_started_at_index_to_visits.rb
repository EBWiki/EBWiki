class AddStartedAtIndexToVisits < ActiveRecord::Migration[5.2]
  def change
    add_index :visits, :started_at
  end
end
