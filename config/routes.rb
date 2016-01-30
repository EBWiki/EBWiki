Rails.application.routes.draw do

  get '/maps/index', to: 'maps#index'

  get '/about', to: 'static#about'
  get '/guidelines', to: 'static#guidelines'
  get '/javascript_lab', to: 'static#javascript_lab'

  get '/sitemap', to: redirect("http://bow-sitemaps.s3.amazonaws.com/sitemaps/sitemap.xml.gz", status: 301)

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  resources :users, only: [:show, :edit]

  get '/articles/:id/history', to: 'articles#history', as: :articles_history
  get '/articles/:id/followers', to: 'articles#followers', as: :articles_followers
  post '/articles/:id/undo', to: 'articles#undo', as: :undo
  resources :articles do
    resources :follows, :only => [:create, :destroy]
    resources :comments
  end

  root 'articles#index'
  resources :users do
    resources :registrations
  end

  # mailbox folder routes
  get "mailbox", to: redirect("mailbox/inbox")
  get "mailbox/inbox" => "mailbox#inbox", as: :mailbox_inbox
  get "mailbox/sent" => "mailbox#sent", as: :mailbox_sent
  get "mailbox/trash" => "mailbox#trash", as: :mailbox_trash

  # conversations
  resources :conversations do
    member do
      post :reply
      post :trash
      post :untrash
    end
  end
end
