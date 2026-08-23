# frozen_string_literal: true

module EbWiki
  class Routes < Hanami::Routes
    root to: "cases.index"

    get "/search", to: "search.show"

    resources :cases, only: %i[index show]
    get "/cases/:case_slug/history", to: "cases.history"

    resources :agencies, only: %i[index show]

    get "/articles", to: "articles.index"
    get "/articles/:slug", to: "articles.show"

    get "/about", to: "pages.show"
    get "/guidelines", to: "pages.show"
    get "/instructions", to: "pages.show"
    get "/get-involved", to: "pages.show"
    get "/how-to-help", to: "pages.show"
  end
end
