# frozen_string_literal: true

RSpec.shared_context 'staging database scrub setup' do
  let!(:user) do
    create(
      :user,
      email: 'real.editor@company.com',
      name: 'Real Editor',
      description: 'Reach me at real.editor@company.com',
      city: 'Brooklyn',
      current_sign_in_ip: '203.0.113.10',
      last_sign_in_ip: '203.0.113.11'
    )
  end

  let!(:case_record) do
    create(
      :case,
      title: 'Published Victim Name',
      overview: 'Overview text stays intact',
      summary: 'Summary text stays intact',
      city: 'Albany'
    )
  end

  let(:case_snapshot) do
    case_record.reload.attributes.slice(
      'title', 'overview', 'summary', 'city', 'address', 'zipcode', 'slug', 'video_url'
    )
  end

  around do |example|
    previous = ENV.fetch('EBWIKI_STAGING_DATABASE_SCRUB_ALLOWED', nil)
    ENV['EBWIKI_STAGING_DATABASE_SCRUB_ALLOWED'] = 'true'
    example.run
  ensure
    if previous.nil?
      ENV.delete('EBWIKI_STAGING_DATABASE_SCRUB_ALLOWED')
    else
      ENV['EBWIKI_STAGING_DATABASE_SCRUB_ALLOWED'] = previous
    end
  end

  before do
    ActiveRecord::Base.connection.execute(<<~SQL.squish)
      INSERT INTO sessions (session_id, data, created_at, updated_at)
      VALUES ('secret-session', '{"user_id":#{user.id}}', NOW(), NOW())
    SQL

    ActiveRecord::Base.connection.execute(<<~SQL.squish)
      INSERT INTO versions (item_type, item_id, event, whodunnit, ip, object, object_changes, created_at)
      VALUES ('User', #{user.id}, 'update', '#{user.email}', '198.51.100.2', 'email: old@example.com', 'email: new@example.com', NOW())
    SQL
  end
end
