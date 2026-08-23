# frozen_string_literal: true

module EbWiki
  class Routes < Hanami::Routes
    root to: "cases.index"

    resources :cases, only: %i[index show]

    get "/articles", to: "articles.index"
    get "/articles/:slug", to: "articles.show"
  end
end
