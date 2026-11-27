# frozen_string_literal: true

require 'rails_helper'
require 'staging_database_scrub'
require_relative 'scrubber_examples'

RSpec.describe StagingDatabaseScrub, '.scrub' do
  include_context 'staging database scrub setup'

  it 'scrubs user personal data, clears sessions, and leaves case rows unchanged' do
    described_class.scrub

    user.reload
    expect(user.email).to eq("scrubbed-user-#{user.id}@example.invalid")
    expect(user.name).to eq("Scrubbed User #{user.id}")
    expect(user.description).to eq('Scrubbed description')
    expect(user.encrypted_password).to be_nil
    expect(user.reset_password_token).to be_nil
    expect(user.confirmation_token).to be_nil
    expect(user.current_sign_in_ip).to be_nil
    expect(user.last_sign_in_ip).to be_nil

    session_count = ActiveRecord::Base.connection
                                       .select_value('SELECT COUNT(*) FROM sessions').to_i
    expect(session_count).to eq(0)

    version_row = ActiveRecord::Base.connection.select_one(<<~SQL.squish)
      SELECT whodunnit, ip, object, object_changes
      FROM versions
      WHERE item_type = 'User' AND item_id = #{user.id}
      ORDER BY id DESC
      LIMIT 1
    SQL
    expect(version_row['whodunnit']).to eq('scrubbed')
    expect(version_row['ip']).to be_nil
    expect(version_row['object']).to be_nil
    expect(version_row['object_changes']).to be_nil

    case_record.reload
    expect(
      case_record.attributes.slice(
        'title', 'overview', 'summary', 'city', 'address', 'zipcode', 'slug', 'video_url'
      )
    ).to eq(case_snapshot)
  end

  it 'is idempotent when run twice' do
    described_class.scrub
    first_email = user.reload.email

    described_class.scrub
    expect(user.reload.email).to eq(first_email)
  end
end
