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
    object.updated_at.to_fs(:stamp)
  end

  def link_to_case_title(this_case, length)
    link_to truncate(this_case.title, length: length), this_case
  end

  def bootstrap_flash_class(key)
    { notice: 'info', alert: 'warning', error: 'danger', success: 'success' }.fetch(key.to_sym, key)
  end

  def social_share_button_tag(text)
    url = ERB::Util.url_encode(request.original_url)
    message = ERB::Util.url_encode(text)
    content_tag(:div, class: 'share-links') do
      safe_join([
                  link_to('Share on X', "https://twitter.com/intent/tweet?text=#{message}&url=#{url}",
                          target: '_blank', rel: 'noopener', class: 'btn btn-sm btn-outline-secondary'),
                  link_to('Share on Facebook', "https://www.facebook.com/sharer/sharer.php?u=#{url}",
                          target: '_blank', rel: 'noopener', class: 'btn btn-sm btn-outline-secondary')
                ], ' ')
    end
  end
end
