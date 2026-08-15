# frozen_string_literal: true

module FriendlyPhotos
  # Applies a reviewed Wikimedia portrait to a case after human approval.
  class ApplyCandidate
    include Service

    Result = Struct.new(:success, :error, keyword_init: true)

    def call(this_case:, candidate:)
      return failure('Candidate does not belong to this case.') unless candidate.case_id == this_case.id
      return failure('Mugshot candidates cannot be applied.') if candidate.likely_mugshot?
      unless WikimediaClient.allowed_image_url?(candidate.image_url)
        return failure('That image is not from an allowed Wikimedia host.')
      end

      apply_to_case(this_case, candidate)
    rescue StandardError => e
      Rollbar.error(e)
      failure("Could not download that photo: #{e.message}")
    end

    private

    def apply_to_case(this_case, candidate)
      this_case.remote_avatar_url = candidate.image_url
      this_case.avatar_kind = 'portrait'
      this_case.summary = apply_summary(candidate)
      return failure(this_case.errors.full_messages.to_sentence) unless this_case.save

      candidate.accepted!
      Result.new(success: true, error: nil)
    end

    def apply_summary(candidate)
      "Applied Wikimedia portrait '#{candidate.title}' as a non-mugshot case photo."
    end

    def failure(message)
      Result.new(success: false, error: message)
    end
  end
end
