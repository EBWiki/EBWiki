class CreateArticleMilestones < ActiveRecord::Migration
  def change
    create_table :article_milestones do |t|
      t.integer :article_id
      t.integer :milestone_id
      t.date :date_occurred

      t.timestamps null: false
    end
  end
end
