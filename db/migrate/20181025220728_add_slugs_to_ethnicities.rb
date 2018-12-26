class AddSlugsToEthnicities < ActiveRecord::Migration
  def change
    add_column :ethnicities, :slug, :string
  end
end
