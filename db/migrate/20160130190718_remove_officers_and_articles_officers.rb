class RemoveOfficersAndArticlesOfficers < ActiveRecord::Migration
  def up
    drop_table :officers
    drop_table :articles_officers
  end

  def down
    create_table :officers do |t|
      t.string :first_name
      t.string :last_name
    end

    create_table :articles_officers, id: false do |t|
      t.belongs_to :articles, index: true
      t.belongs_to :officers, index: true
    end
  end
end
