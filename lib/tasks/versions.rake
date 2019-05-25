# frozen_string_literal: true

namespace :versions do
  desc 'Set all nil comment attributes on versions to empty string'
  task set_nil_comment: :environment do
    sql_query = <<-END_SQL
      UPDATE versions
      SET comment = ''
      WHERE comment IS NULL;
    END_SQL

    ActiveRecord::Base.connection.execute(sql_query)
  end
end
