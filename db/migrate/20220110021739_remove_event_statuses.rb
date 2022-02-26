class RemoveEventStatuses < ActiveRecord::Migration[5.2]
  def change
    drop_table(:event_statuses, if_exists: true)
  end
end
