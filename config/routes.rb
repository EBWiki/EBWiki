# frozen_string_literal: true

Rails.application.routes.draw do
  get 'analytics/index'

  get '/maps/index', to: 'maps#index'

  get '/about', to: 'static#about'
  get '/guidelines', to: 'static#guidelines'
  get '/javascript_lab', to: 'static#javascript_lab'
  get '/contribution_guidelines', to: 'static#contribution_guidelines'

  get '/sitemap', to: redirect('http://bow-sitemaps.s3.amazonaws.com/sitemaps/sitemap.xml.gz', status: 301)

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  resources :users, only: %i[show edit]
  resources :agencies

  get '/cases/:id/history', to: 'cases#history', as: :cases_history
  get '/cases/:id/followers', to: 'cases#followers', as: :cases_followers
  post '/cases/:id/undo', to: 'cases#undo', as: :undo

  match '/articles', to: redirect('/cases', status: 301), via: :all
  match '/articles/*action', to: redirect { |p, _| "/cases/#{p[:action]}" }, via: :all

  resources :cases do
    resources :follows, only: %i[create destroy]
    resources :comments
  end

  root 'cases#index'
  resources :users do
    resources :registrations
  end

  mount Split::Dashboard, at: 'split', anchor: false, constraints: lambda { |request|
    request.env['warden'].authenticated? # are we authenticated?
    request.env['warden'].authenticate! # authenticate if not already
    # or even check any other condition
    request.env['warden'].user.admin?
  }

  # mailbox folder routes
  get 'mailbox', to: redirect('mailbox/inbox')
  get 'mailbox/inbox' => 'mailbox#inbox', as: :mailbox_inbox
  get 'mailbox/sent' => 'mailbox#sent', as: :mailbox_sent
  get 'mailbox/trash' => 'mailbox#trash', as: :mailbox_trash

  # conversations
  resources :conversations do
    member do
      post :reply
      post :trash
      post :untrash
    end
  end

  # CKEditor
  mount Ckeditor::Engine => '/ckeditor'
end
