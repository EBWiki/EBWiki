class AddBackgroundToOfficer < ActiveRecord::Migration
  def change
    add_column :officers, :background, :text
  end
end
