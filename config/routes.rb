# frozen_string_literal: true

SITEMAP_URL = ENV.fetch('EBWIKI_SITEMAP_URL').freeze

Rails.application.routes.draw do
  root 'cases#index'

  get '/analytics/users_by_day', to: 'analytics#users_by_day'
  get '/analytics/visits_by_browser', to: 'analytics#visits_by_browser'
  get '/analytics/visits_by_day', to: 'analytics#visits_by_day'
  get '/analytics/visits_by_referring_domain', to: 'analytics#visits_by_referring_domain'
  get '/analytics', to: 'analytics#index'

  get '/maps', to: 'maps#index'

  get '/about', to: 'static#about'
  get '/guidelines', to: 'static#guidelines'
  get '/javascript_lab', to: 'static#javascript_lab'
  get '/instructions', to: 'static#instructions'

  get '/sitemap', to: redirect(SITEMAP_URL, status: 301)

  mount RailsAdmin::Engine, at: '/admin', as: 'rails_admin'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  resources :users, only: %i[show edit]
  resources :agencies

  get '/cases/:case_slug/history', to: 'cases#history', as: :cases_history
  get '/cases/:case_slug/followers', to: 'cases#followers', as: :cases_followers
  post '/cases/:case_slug/undo', to: 'cases#undo', as: :undo

  get '/articles', to: redirect('/cases', status: 301)
  namespace 'articles' do
    %w[index edit show destroy update history new create followers undo].each do |action|
      get action, action: action
    end
  end
  match '/articles/*action', to: redirect { |p, _| "/cases/#{p[:action]}" }, via: :all

  resources :cases do
    resources :follows, only: %i[create destroy]
    resources :comments
    scope module: 'cases' do
      post 'versions/:id/revert', to: 'versions#revert', as: :revert
    end
  end

  resources :users do
    member do
      patch 'update_email'
    end
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
  get 'mailbox/inbox', to: 'mailbox#inbox', as: :mailbox_inbox
  get 'mailbox/sent', to: 'mailbox#sent', as: :mailbox_sent
  get 'mailbox/trash', to: 'mailbox#trash', as: :mailbox_trash

  # conversations
  resources :conversations do
    member do
      post :reply
      post :trash
      post :untrash
    end
  end

  # CKEditor
  mount Ckeditor::Engine, at: '/ckeditor'

  resource :search, controller: 'search'
end
