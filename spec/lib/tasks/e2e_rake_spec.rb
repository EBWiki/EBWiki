# frozen_string_literal: true

require 'rails_helper'

describe 'e2e:seed_friendly_photos' do
  include_context 'rake'

  it 'seeds the playwright fixtures' do
    allow(FriendlyPhotos::E2eSeed).to receive(:call)

    expect { subject.invoke }.to output(/Seeded e2e friendly photo fixtures/).to_stdout
    expect(FriendlyPhotos::E2eSeed).to have_received(:call)
  end
end
