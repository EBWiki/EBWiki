# frozen_string_literal: true

Rails.application.routes.draw do
  default_url_options host: "example.com"
  root 'cases#index'

  resources :cases do
    member do
      post 'follows', to: 'follows#create'
      delete 'follows', to: 'follows#destroy'
    end
    resources :comments, only: %i[index create]
  
  end
  
  get '/cases/:case_slug/followers', to: 'cases#followers', as: :cases_followers

  # redirect logic
  get '/articles', to: redirect('/cases')
  get '/articles/:slug', to: redirect { |path_params, _req| "/cases/#{path_params[:slug]}" }
  get '/articles/:slug/followers', to: redirect { |path_params, _req| "/cases/#{path_params[:slug]}/followers" }

  resources :agencies
  resources :organizations
  resources :maps

  devise_for :users, controllers: { registrations: 'users/registrations' }
  resources :users, only: %i[show edit update]
  mount RailsAdmin::Engine, at: '/admin', as: 'rails_admin'

  get '/about', to: 'static#about'
  get '/guidelines', to: 'static#guidelines'
  get '/javascript_lab', to: 'static#javascript_lab'
  get '/instructions', to: 'static#instructions'
  get '/get-involved', to: 'static#further_actions'
  get '/how-to-help', to: 'static#how_to_help'

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
