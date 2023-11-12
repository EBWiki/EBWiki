class ValidateNameUniquenessOnAgencies < ActiveRecord::Migration[5.2]
  def change
    change_column :agencies, :name, :string, unique: true
  end
end
