class RemoveArticleMilestones < ActiveRecord::Migration
  def up
    drop_table :milestones
    drop_table :article_milestones
  end

  def down
    create_table :milestones do |t|
      t.string :title

      t.timestamps null: false
    end

    create_table :article_milestones do |t|
      t.integer :article_id
      t.integer :milestone_id
      t.date :date
      t.text :description
      t.boolean :include

      t.timestamps null: false
    end
  end
end
