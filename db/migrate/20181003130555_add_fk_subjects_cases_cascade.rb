class AddFkSubjectsCasesCascade < ActiveRecord::Migration
  def change
    add_foreign_key :subjects, :cases, on_delete: :cascade
  end
end
