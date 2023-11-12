class AddFkSubjectsCasesCascade < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :subjects, :cases, on_delete: :cascade
  end
end
