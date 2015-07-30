class ChangeArmedToUnarmedInSubject < ActiveRecord::Migration
  def change
    rename_column :subjects, :armed, :unarmed
  end
end
