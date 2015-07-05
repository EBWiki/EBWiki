class DropEvents < ActiveRecord::Migration
  def change
  	drop_table :events if ActiveRecord::Base.connection.table_exists? :events
  end
end
