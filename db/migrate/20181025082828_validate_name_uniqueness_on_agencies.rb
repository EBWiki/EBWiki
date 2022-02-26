class ValidateNameUniquenessOnAgencies < ActiveRecord::Migration
  def change
    change_column :agencies, :name, :string, unique: true
  end
end
