class FixColumnNameInSubject < ActiveRecord::Migration
  def change
  	rename_column :subjects, :ethnicity, :ethnicity_id
  	rename_column :subjects, :gender, :gender_id
  end
end
