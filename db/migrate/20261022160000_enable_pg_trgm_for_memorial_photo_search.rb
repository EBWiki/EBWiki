# frozen_string_literal: true

class EnablePgTrgmForMemorialPhotoSearch < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')
  end
end
