class CreateRolloutHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :rollout_histories do |t|
      t.string :rollout_name, null: false
      t.date :change_date, null: false
      t.text :change_description, null: false
      t.string :author_name, null: false

      t.timestamps
    end
  end
end
