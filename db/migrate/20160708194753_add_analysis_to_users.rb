class AddAnalysisToUsers < ActiveRecord::Migration
  def change
    add_column :users, :analyst, :boolean, :default => false
  end
end
