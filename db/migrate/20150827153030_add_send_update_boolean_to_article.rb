class AddSendUpdateBooleanToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :send_update, :boolean unless Article.column_names.include?('send_update')
  end
end
