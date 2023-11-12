class ValidateTitlePresenceOnCases < ActiveRecord::Migration[5.2]
  def change
  	change_column :cases, :title, :string, null: false
  end
end
