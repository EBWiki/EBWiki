# frozen_string_literal: true

module ApplicationHelper
  def active_page(active_page)
    @active == active_page ? 'active' : ''
  end

  def avatar_url(user, size)
    default_url = "#{root_url}default-user-icon.png"
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end

  def filter
    if params[:controller] == 'maps'
      '/maps/index'
    else
      'articles'
    end
  end

  def marker_locations_for(articles)
    return nil if articles.blank?
    @hash = Gmaps4rails.build_markers(articles) do |article, marker|
      marker.lat article[1]
      marker.lng article[2]
      marker.infowindow controller.render_to_string(partial: '/articles/info_window', locals: { article: article })
    end
    @hash
  end

  def active_page_link(page, remote)
    content_tag :a, page, remote: remote, rel: (page.next? ? 'next' : (page.prev? ? 'prev' : nil))
  end

  def page_link(page, url, remote)
    link_to page, url, remote: remote, rel: (page.next? ? 'next' : (page.prev? ? 'prev' : nil))
  end
end
