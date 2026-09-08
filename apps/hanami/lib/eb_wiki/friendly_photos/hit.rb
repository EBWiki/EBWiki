# frozen_string_literal: true

module EbWiki
  module FriendlyPhotos
    Hit = Struct.new(
      :source,
      :title,
      :image_url,
      :page_url,
      :license,
      :author,
      :description,
      :likely_mugshot,
      keyword_init: true
    )
  end
end
