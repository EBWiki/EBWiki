class ChangeEnumNamePrivate < ActiveRecord::Migration
  def new_enumlabels(enum_type, old_value, new_value)
  	enumlabels = ActiveRecord::Base.connection.execute <<-SQL
        SELECT jurisdiction from pg_enum WHERE enumtypid=( 
          SELECT oid FROM pg_type WHERE typname=’jurisdiction’
        ) ORDER BY enumsortorder;
      SQL 
    enumlables = enumlabels.map { |e| "e["jurisdiction"]" } — ["private"] + ["not_provided"] }
    enumlabels = enumlables.uniq.join(",").chomp(",")
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TYPE jurisdiction ADD VALUE IF NOT EXISTS not_provided;
  SQL
  ActiveRecord::Base.connection.execute <<-SQL
      ALTER TYPE jursidiction RENAME TO old_jurisdiction;
      CREATE TYPE jurisdiction AS ENUM ('unknown', 'local', 'state', 'federal', 'university', 'not_provided');
      ALTER TABLE agencies ALTER COLUMN jurisdiction TYPE jurisdiction USING jurisdiction::text::jurisdiction; 
      DROP TYPE old_jurisdiction; 
SQL
  end
end
