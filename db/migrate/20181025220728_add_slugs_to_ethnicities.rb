class AddSlugsToEthnicities < ActiveRecord::Migration[5.2]
  def change
    add_column :ethnicities, :slug, :string
  end
end
