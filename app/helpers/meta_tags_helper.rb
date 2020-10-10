# frozen_string_literal: true

# Helper module to generate meta tags for views
module MetaTagsHelper
  def meta_title
    content_for(:meta_title).presence || DEFAULT_META['meta_title']
  end

  def meta_description
    content_for(:meta_description).presence || DEFAULT_META['meta_description']
  end

  # second statement enables functionality for both assets and urls
  def meta_image
    meta_image = content_for(:meta_image).presence || DEFAULT_META['meta_image']
    meta_image.starts_with?('http') ? meta_image : image_url(meta_image)
  end

  def meta_keywords
    content_for(:meta_keywords).presence || DEFAULT_META['meta_keywords']
  end
end
