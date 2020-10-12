class AddSlugToStates < ActiveRecord::Migration
  def change
    add_column :states, :slug, :string
  end
end
