# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, skip: %i[registrations passwords sessions]
  devise_scope :user do
    get 'webauth/login' => 'login#login', as: :new_user_session
    get 'webauth/logout' => 'devise/sessions#destroy',
        as: :destroy_user_session,
        via: Devise.mappings[:user].sign_out_via
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'welcome#show'
  resources :accounts, only: :show
  resource :dashboard, only: :show
  resource :search, only: :show
  resources :collections, only: %i[show edit update destroy] do
    member do
      get :deposit_button
      get :delete_button
      get :edit_link
      get :dashboard
    end

    resources :works, shallow: true do
      member do
        get :delete_button
        get :edit_button
        get :next_step
        get :next_step_review
      end

      resource :review, only: :create
      resource :validate, only: :show
      resource :zip, only: :show
    end

    resources :reservations, shallow: true, only: %i[create update]
  end

  resource :terms, only: :show

  resources :first_draft_collections, only: %i[new create edit update]
  resources :collection_versions, only: %i[show destroy edit update] do
    member do
      get :edit_link
    end
  end
  resources :work_versions, only: :destroy

  resource :admin, only: :show
  namespace :admin do
    resources :users, only: :index
    resources :collection_reports, only: %i[new create]
  end

  # This route is used by the emails for the contact the SDR team link.
  direct :contact_form do
    { controller: 'welcome', action: 'show', anchor: 'help' }
  end
  resource :help, only: %i[new create]
  get 'print_terms_of_deposit', to: 'print#terms_of_deposit'

  get 'autocomplete', to: 'autocomplete#show', defaults: { format: 'html' }

  get 'orcid', to: 'orcid#search'

  # @note Only admins should be able to access the Sidekiq web UI.  But this is accomplished by Puppet
  # configuration restricting access using a shib workgroup, so the request doesn't reach the app if the user
  # isn't authorized (because ApplicationController#current_user doesn't get called until after this runs).
  mount Sidekiq::Web => '/queues'
end
