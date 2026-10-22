# frozen_string_literal: true

module CasePhotoRequests
  # Clears requester_contact on resolved requests whose retention window has passed.
  class PurgeStaleContacts
    def self.call
      new.call
    end

    def call
      due_requests.find_each do |request|
        request.purge_requester_contact!
      rescue StandardError => e
        ErrorReporter.report(e, case_photo_change_request_id: request.id)
      end
    end

    private

    def due_requests
      CasePhotoChangeRequest.resolved
                            .where.not(requester_contact: [nil, ''])
                            .where(contact_purge_after: ..Time.current)
    end
  end
end
