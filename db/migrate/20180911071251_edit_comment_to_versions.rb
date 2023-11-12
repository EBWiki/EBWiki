# frozen_string_literal: true

class EditCommentToVersions < ActiveRecord::Migration[5.2]
  def change
    change_column :versions, :comment, :text, default: ''
  end
end
