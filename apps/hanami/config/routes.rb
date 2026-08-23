# frozen_string_literal: true

module EbWiki
  class Routes < Hanami::Routes
    root to: "cases.index"

    get "/search", to: "search.show"

    get "/login", to: "sessions.new"
    post "/login", to: "sessions.create"
    post "/logout", to: "sessions.destroy"

    resources :cases, only: %i[index show new create edit update]
    get "/cases/:case_slug/history", to: "cases.history"
    post "/cases/:case_id/comments", to: "comments.create"
    post "/cases/:case_id/follows", to: "follows.create"
    post "/cases/:case_id/unfollow", to: "follows.destroy"

    resources :agencies, only: %i[index show]
    resources :organizations, only: %i[index show]

    get "/articles", to: "articles.index"
    get "/articles/:slug", to: "articles.show"

    get "/about", to: "pages.show"
    get "/guidelines", to: "pages.show"
    get "/instructions", to: "pages.show"
    get "/get-involved", to: "pages.show"
    get "/how-to-help", to: "pages.show"

    get "/admin/users", to: "admin.users.index"
    patch "/admin/users/:id", to: "admin.users.update"
    post "/admin/users/:id", to: "admin.users.update"
  end
end
