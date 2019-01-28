class AddStartedAtIndexToVisits < ActiveRecord::Migration
  def change
    add_index :visits, :started_at
  end
end
