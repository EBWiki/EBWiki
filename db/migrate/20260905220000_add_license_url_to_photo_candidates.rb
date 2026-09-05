# frozen_string_literal: true

class AddLicenseUrlToPhotoCandidates < ActiveRecord::Migration[8.1]
  def change
    add_column :photo_candidates, :license_url, :string
  end
end
