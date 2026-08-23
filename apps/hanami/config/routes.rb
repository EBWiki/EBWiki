# frozen_string_literal: true

module EbWiki
  class Routes < Hanami::Routes
    root to: "cases.index"

    get "/search", to: "search.show"

    get "/login", to: "sessions.new"
    post "/login", to: "sessions.create"
    post "/logout", to: "sessions.destroy"
    get "/register", to: "registrations.new"
    post "/register", to: "registrations.create"
    get "/users/confirmation", to: "confirmations.show"
    get "/password/new", to: "passwords.new"
    post "/password", to: "passwords.create"
    get "/password/edit", to: "passwords.edit"
    post "/password/update", to: "passwords.update"

    resources :users, only: %i[show edit update]
    post "/users/:id", to: "users.update"
    resources :cases, only: %i[index show new create edit update]
    get "/cases/:case_slug/history", to: "cases.history"
    post "/cases/:case_slug/history/:version_id/revert", to: "cases.revert"
    post "/cases/:case_id/comments", to: "comments.create"
    post "/comments/:id/delete", to: "comments.destroy"
    post "/cases/:case_id/follows", to: "follows.create"
    post "/cases/:case_id/unfollow", to: "follows.destroy"

    resources :agencies, only: %i[index show new create edit update]
    post "/agencies/:id", to: "agencies.update"
    resources :organizations, only: %i[index show new create edit update]
    post "/organizations/:id", to: "organizations.update"

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
