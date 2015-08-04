class CreateArticleMilestones < ActiveRecord::Migration
  def change
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
