# frozen_string_literal: true

module FriendlyPhotos
  # Applies a reviewed Wikimedia portrait to a case after human approval.
  class ApplyCandidate
    include Service

    Result = Struct.new(:success, :error, keyword_init: true)

    def call(this_case:, candidate:)
      error = rejection_reason(this_case, candidate)
      return failure(error) if error
      return stub_apply(this_case, candidate) if WikimediaClient.stubbed?

      apply_to_case(this_case, candidate)
    rescue StandardError => e
      Rollbar.error(e)
      failure("Could not download that photo: #{e.message}")
    end

    private

    def rejection_reason(this_case, candidate)
      return 'Candidate does not belong to this case.' if candidate.case_id != this_case.id
      return 'Mugshot candidates cannot be applied.' if candidate.likely_mugshot?
      if candidate.license.blank? && candidate.license_url.blank?
        return 'That candidate has no recorded license or rights path.'
      end
      return if SourcePolicy.allowed_attach_url?(candidate.image_url)

      'That image is not from an allowed Wikimedia or Openverse host.'
    end

    def stub_apply(this_case, candidate)
      this_case.update_columns( # rubocop:disable Rails/SkipsModelValidations
        avatar_kind: 'portrait',
        default_avatar_url: candidate.image_url
      )
      candidate.accepted!
      Result.new(success: true, error: nil)
    end

    def apply_to_case(this_case, candidate)
      this_case.remote_avatar_url = candidate.image_url
      this_case.avatar_kind = 'portrait'
      this_case.summary = apply_summary(candidate)
      return failure(this_case.errors.full_messages.to_sentence) unless this_case.save

      candidate.accepted!
      Result.new(success: true, error: nil)
    end

    def apply_summary(candidate)
      "Applied reviewed portrait '#{candidate.title}' (#{candidate.license}) " \
        'as a non-mugshot case photo.'
    end

    def failure(message)
      Result.new(success: false, error: message)
    end
  end
end
