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
    object.updated_at.to_s(:stamp)
  end

  def link_to_case_title(this_case, length)
    link_to truncate(this_case.title, length: length), this_case
  end
end
