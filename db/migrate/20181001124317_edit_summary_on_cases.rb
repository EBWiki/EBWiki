class EditSummaryOnCases < ActiveRecord::Migration
  def change
  	change_column :cases, :summary, :text, null: false
  end
end
