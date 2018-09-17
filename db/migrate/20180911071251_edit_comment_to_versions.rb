# frozen_string_literal: true

class EditCommentToVersions < ActiveRecord::Migration
  def change
    change_column :versions, :comment, :text, default: ''
  end
end
