class AddBlurbToVersion < ActiveRecord::Migration
  def change
    add_column :versions, :blurb, :text unless PaperTrail::Version.column_names.include?('blurb')
  end
end
