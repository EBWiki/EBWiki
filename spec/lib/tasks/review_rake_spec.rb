# frozen_string_literal: true

require 'rails_helper'

describe 'review:deploy_prepare' do
  include_context 'rake'

  it 'migrates, ensures sessions, resets the db pool, then seeds in one process' do
    allow(ActiveRecord::Tasks::DatabaseTasks).to receive(:migrate)
    allow(ReviewSessionsTable).to receive(:ensure!)
    allow(ReviewDbConnection).to receive(:reset_pool!)
    allow(FriendlyPhotos::E2eSeed).to receive(:call)

    expect { subject.invoke }.to output(/Review server seeded/).to_stdout

    expect(ActiveRecord::Tasks::DatabaseTasks).to have_received(:migrate).ordered
    expect(ReviewSessionsTable).to have_received(:ensure!).ordered
    expect(ReviewDbConnection).to have_received(:reset_pool!).ordered
    expect(FriendlyPhotos::E2eSeed).to have_received(:call).ordered
  end
end

describe 'review:seed' do
  include_context 'rake'

  it 'resets the db pool before seeding' do
    allow(ReviewDbConnection).to receive(:reset_pool!)
    allow(FriendlyPhotos::E2eSeed).to receive(:call)

    expect { subject.invoke }.to output(/Review server seeded/).to_stdout

    expect(ReviewDbConnection).to have_received(:reset_pool!)
    expect(FriendlyPhotos::E2eSeed).to have_received(:call)
  end
end
