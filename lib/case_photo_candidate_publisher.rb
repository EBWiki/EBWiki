# frozen_string_literal: true

require 'httparty'
require 'tempfile'

# Attaches an approved remote photo to a case after human review.
class CasePhotoCandidatePublisher
  class Error < StandardError; end

  MAX_BYTES = 8.megabytes
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze

  def initialize(candidate, reviewer:)
    @candidate = candidate
    @reviewer = reviewer
  end

  def approve!
    raise Error, 'Only pending candidates can be approved.' unless @candidate.pending?
    raise Error, 'This case already has a photo.' if @candidate.case.avatar?

    ActiveRecord::Base.transaction do
      attach_avatar!
      @candidate.update!(
        status: :approved,
        reviewed_by: @reviewer,
        reviewed_at: Time.current,
        rejection_reason: nil
      )
    end
  end

  def reject!(reason: nil)
    raise Error, 'Only pending candidates can be rejected.' unless @candidate.pending?

    @candidate.update!(
      status: :rejected,
      reviewed_by: @reviewer,
      reviewed_at: Time.current,
      rejection_reason: reason
    )
  end

  private

  def attach_avatar!
    response = HTTParty.get(@candidate.image_url, follow_redirects: true, timeout: 30)
    raise Error, 'Could not download the image.' unless response.success?

    content_type = response.headers['content-type'].to_s.split(';').first.strip.downcase
    unless ALLOWED_CONTENT_TYPES.include?(content_type)
      raise Error, 'Downloaded file is not a supported image type.'
    end

    body = response.body
    raise Error, 'Downloaded image is empty.' if body.blank?
    raise Error, 'Downloaded image is too large.' if body.bytesize > MAX_BYTES

    extension = extension_for(content_type)
    file = Tempfile.new(['case_photo_candidate', extension])
    file.binmode
    file.write(body)
    file.rewind

    @candidate.case.avatar = file
    @candidate.case.save!
  ensure
    file&.close
    file&.unlink
  end

  def extension_for(content_type)
    case content_type
    when 'image/jpeg' then '.jpg'
    when 'image/png' then '.png'
    when 'image/gif' then '.gif'
    when 'image/webp' then '.webp'
    else '.jpg'
    end
  end
end
