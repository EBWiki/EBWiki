class ValidateTitlePresenceOnCases < ActiveRecord::Migration
  def change
  	change_column :cases, :title, :string, null: false
  end
end
