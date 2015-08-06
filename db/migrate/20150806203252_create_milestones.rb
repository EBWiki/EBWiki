class CreateMilestones < ActiveRecord::Migration
  def change
    create_table :milestones do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
