# frozen_string_literal: true

module PhotoFinder
  Candidate = Data.define(
    :image_url,
    :source_page_url,
    :source_name,
    :license_label,
    :license_url,
    :title,
    :description
  ) do
    def context_text
      [title, description, source_page_url, image_url].compact.join(' ')
    end
  end
end
