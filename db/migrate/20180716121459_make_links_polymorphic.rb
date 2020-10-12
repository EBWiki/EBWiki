class MakeLinksPolymorphic < ActiveRecord::Migration
  def up
    rename_column :links, :case_id, :linkable_id
    add_column :links, :linkable_type, :string
    Link.reset_column_information
    Link.update_all(:linkable_type => "Case")
    add_index :links, [:linkable_id, :linkable_type]
  end

  def down
    remove_index :links, [:linkable_id, :linkable_type]
    rename_column :links, :linkable_id, :case_id
    remove_column :links, :linkable_type
    add_foreign_key "links", "cases"
  end
end
