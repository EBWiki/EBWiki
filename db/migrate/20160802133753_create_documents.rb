class CreateDocuments < ActiveRecord::Migration
  def change
    if table_exists?(:documents)
      drop_table(:documents)
    end
    create_table :documents do |t|
      t.string :title
      t.string :attachment

      t.timestamps null: false
    end
  end
end
