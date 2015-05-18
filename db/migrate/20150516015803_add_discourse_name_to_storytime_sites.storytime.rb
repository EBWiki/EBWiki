# This migration comes from storytime (originally 20150331162329)
class AddDiscourseNameToStorytimeSites < ActiveRecord::Migration
  def change
    add_column :storytime_sites, :discourse_name, :string
  end
end
