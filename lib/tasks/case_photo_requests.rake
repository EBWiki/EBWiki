# frozen_string_literal: true

namespace :case_photo_requests do
  desc 'Clear requester contact fields past their retention date'
  task purge_contacts: :environment do
    CasePhotoRequests::PurgeStaleContacts.call
  end
end
