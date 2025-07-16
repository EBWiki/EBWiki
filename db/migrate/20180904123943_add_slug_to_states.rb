class AddSlugToStates < ActiveRecord::Migration[5.2]
  def change
    add_column :states, :slug, :string
  end
end
