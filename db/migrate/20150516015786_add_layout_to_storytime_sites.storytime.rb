# This migration comes from storytime (originally 20150224193551)
class AddLayoutToStorytimeSites < ActiveRecord::Migration
  def change
    add_column :storytime_sites, :layout, :string
  end
end
