# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasePhotoRequests::PurgeStaleContacts do
  it 'clears contact after the purge date' do
    request = create(:case_photo_change_request, requester_contact: 'keep@example.com')
    request.resolve!
    request.update!(contact_purge_after: 1.day.ago)

    described_class.call

    expect(request.reload.requester_contact).to be_nil
  end

  it 'leaves contact before the purge date' do
    request = create(:case_photo_change_request, requester_contact: 'keep@example.com')
    request.resolve!

    described_class.call

    expect(request.reload.requester_contact).to eq('keep@example.com')
  end
end
