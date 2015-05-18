# This migration comes from storytime (originally 20150302192759)
class SeedPermissions < ActiveRecord::Migration
  def up
    Storytime::Permission.reset_column_information
    Storytime::Permission.seed
  end
  
  def down
  end
end
