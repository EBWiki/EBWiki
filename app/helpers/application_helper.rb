# frozen_string_literal: true

# Main helper for the site. Helpers meant to be applicable to all pages
module ApplicationHelper
  def active_page(active_page)
    @active == active_page ? 'active' : ''
  end

  def avatar_url(user, size)
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end

  def filter
    if params[:controller] == 'maps'
      '/maps/index'
    else
      'cases'
    end
  end

  def marker_locations_for(cases)
    return nil if cases.blank?
    @hash = Gmaps4rails.build_markers(cases) do |this_case, marker|
      marker.lat this_case[1]
      marker.lng this_case[2]
      marker.infowindow controller.render_to_string(
        partial: '/cases/info_window',
        locals: { this_case: this_case }
      )
    end
    @hash
  end

  def active_page_link(page, remote)
    content_tag :a, page, remote: remote, rel: link_text(page)
  end

  def page_link(page, url, remote)
    link_to page, url, remote: remote, rel: link_text(page)
  end

  def link_text(page)
    return 'next' if page.next?
    return 'prev' if page.prev?
    nil
  end

  def display_updated_at(object)
    object.updated_at.strftime('%m.%e, %l:%M %p')
  end

  def link_to_case_title(this_case, length)
    link_to truncate(this_case.title, length: length), this_case
  end

  def default_meta_tags
    {
      title:       'EBWiki - Ending Violence Against People of Color',
      description: 'EBWiki is a new web application
       working to harness the power of community to end
       bias in law enforcement that has led to disparate
       treatment of people of color with tragic
       results.',
      keywords: %w[police killing abuse]
    }
  end
end
