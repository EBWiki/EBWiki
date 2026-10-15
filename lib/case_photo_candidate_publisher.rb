# frozen_string_literal: true

require 'tempfile'

require_relative 'photo_finder/allowed_image_fetcher'

# Attaches an approved remote photo to a case after human review.
class CasePhotoCandidatePublisher
  class Error < StandardError; end

  MAX_BYTES = 8.megabytes
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
  CONTENT_TYPE_EXTENSIONS = {
    'image/jpeg' => '.jpg',
    'image/png' => '.png',
    'image/gif' => '.gif',
    'image/webp' => '.webp'
  }.freeze

  def initialize(candidate, reviewer:)
    @candidate = candidate
    @reviewer = reviewer
  end

  def approve!
    raise Error, 'Only pending candidates can be approved.' unless @candidate.pending?
    raise Error, 'This case already has a photo.' if @candidate.case.avatar?

    ActiveRecord::Base.transaction do
      attach_avatar!
      record_approval!
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

  def record_approval!
    @candidate.update!(
      status: :approved,
      reviewed_by: @reviewer,
      reviewed_at: Time.current,
      rejection_reason: nil
    )
  end

  def attach_avatar!
    response = download_image
    body = response.body
    content_type = normalized_content_type(response)
    validate_download!(body, content_type)

    write_avatar_file(body, CONTENT_TYPE_EXTENSIONS.fetch(content_type, '.jpg'))
  end

  def download_image
    PhotoFinder::AllowedImageFetcher.fetch(@candidate.image_url, timeout: 30)
  rescue PhotoFinder::AllowedImageFetcher::Error => e
    raise Error, e.message
  end

  def normalized_content_type(response)
    response.headers['content-type'].to_s.split(';').first.strip.downcase
  end

  def validate_download!(body, content_type)
    unless ALLOWED_CONTENT_TYPES.include?(content_type)
      raise Error, 'Downloaded file is not a supported image type.'
    end
    raise Error, 'Downloaded image is empty.' if body.blank?
    raise Error, 'Downloaded image is too large.' if body.bytesize > MAX_BYTES
  end

  def write_avatar_file(body, extension)
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
end
