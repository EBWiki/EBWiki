# frozen_string_literal: true

require 'rails_helper'

describe 'review:seed' do
  include_context 'rake'

  it 'resets the db pool on review servers before seeding' do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('REVIEW_SERVER').and_return('1')
    allow(ReviewDbConnection).to receive(:reset_pool!)
    allow(FriendlyPhotos::E2eSeed).to receive(:call)

    expect { subject.invoke }.to output(/Review server seeded/).to_stdout

    expect(ReviewDbConnection).to have_received(:reset_pool!)
    expect(FriendlyPhotos::E2eSeed).to have_received(:call)
  end
end
