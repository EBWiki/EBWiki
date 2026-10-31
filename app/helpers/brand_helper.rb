# frozen_string_literal: true

module BrandHelper
  WORDMARKS = {
    on_dark: "brand/wordmark-a-white.svg",
    on_light: "brand/wordmark-a.svg"
  }.freeze

  def ebwiki_wordmark(variant: :on_dark, css_class: "ebwiki-wordmark", small: false)
    path = WORDMARKS.fetch(variant)
    path = "brand/wordmark-a-16-white.svg" if small && variant == :on_dark
    path = "brand/wordmark-a-16.svg" if small && variant == :on_light

    svg = Rails.root.join("app/assets/images", path).read
    tag.span(svg.html_safe, class: css_class, role: "img", aria: { label: "EBWiki" })
  end
end
