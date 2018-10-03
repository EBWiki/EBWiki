describe 'versions:set_nil_comment' do
  include_context 'rake'

  before do
    sql_query = <<-END_SQL
      INSERT INTO versions (item_type, item_id, event, comment)
      VALUES ('users', 1, 'update', null);
    END_SQL

    ActiveRecord::Base.connection.execute(sql_query)
  end

  it 'should update the table' do
    sql_query = <<-END_SQL
      SELECT * 
      FROM versions
      WHERE comment IS NULL
    END_SQL

    results = ActiveRecord::Base.connection.execute(sql_query)
    expect(results.ntuples).to_not eq 0

    subject.invoke
    results = ActiveRecord::Base.connection.execute(sql_query)
    expect(results.ntuples).to eq 0
  end
end
