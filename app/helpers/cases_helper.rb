# frozen_string_literal: true

# Helper for case page, mostly the casw show page.
module CasesHelper
  def embed(video_url)
    return '' if video_url.blank?
    if video_url.include? 'youtube.com'
      youtube_id = video_url.to_s.split('=').last
      content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
    elsif video_url.include? 'vimeo.com'
      vimeo_id = video_url.to_s.split('.com/').last
      content_tag(:iframe, nil, src: "https://player.vimeo.com/video/#{vimeo_id}")
    else
      content_tag(:iframe, nil, src: video_url.to_s)
    end
  end

  # This method checks to make sure that the case has the instance variables
  # it needs in order to display the content. Intended to gracefully fail in cases
  # where an case doesn't have a subject, for example...
  # TODO: Add the location hash to the list of required data
  def case_sanity_check
    (@case.present? &&
      @commentable.present? &&
      @comment.present? &&
      @subjects.present?)
  end

  def link_to_case_title(this_case, length)
    link_to truncate(this_case.title, length: length), this_case
  end
  
  def case_updated_at(this_case)
    this_case.updated_at.strftime('%m.%e,%l:%M %p')
  end

  def make_undo_link
    view_context.link_to 'Undo that please!', versions_revert_path(@case.versions.last), method: :post
  end

  def make_redo_link
    link = params[:redo] == 'true' ? 'Undo that please!' : 'Redo that please!'
    view_context.link_to link, undo_path(@case_version.next, redo: !params[:redo]), method: :post
  end
end
