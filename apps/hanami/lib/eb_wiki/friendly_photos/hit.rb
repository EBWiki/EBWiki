# frozen_string_literal: true

module EbWiki
  module FriendlyPhotos
    Hit = Struct.new(
      :source,
      :title,
      :image_url,
      :page_url,
      :license,
      :license_url,
      :author,
      :description,
      :likely_mugshot
    )
  end
end
