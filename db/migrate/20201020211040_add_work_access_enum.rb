class AddWorkAccessEnum < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE work_access AS ENUM ('stanford', 'world');
      ALTER TABLE works ALTER COLUMN access TYPE work_access USING access::work_access;
      ALTER TABLE works ALTER COLUMN access SET DEFAULT 'world'::work_access;
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE works ALTER COLUMN access TYPE varchar;
      ALTER TABLE works ALTER COLUMN access DROP DEFAULT;
      DROP TYPE work_access;
    SQL
  end
end
