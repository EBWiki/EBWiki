class EditSummaryOnCases < ActiveRecord::Migration[5.2]
  def change
  	change_column :cases, :summary, :text, null: false
  end
end
