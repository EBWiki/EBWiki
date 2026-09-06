# frozen_string_literal: true

class AddAiTrackingToPhotoCandidates < ActiveRecord::Migration[7.1]
  def change
    change_table :photo_candidates, bulk: true do |t|
      t.boolean :planner_ai_used, default: false, null: false
      t.boolean :vision_ai_used, default: false, null: false
      t.boolean :vision_failed, default: false, null: false
      t.boolean :likely_homonym, default: false, null: false
    end
  end
end
