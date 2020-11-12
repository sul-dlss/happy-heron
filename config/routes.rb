# typed: strict
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
  resource :dashboard, only: :show

  resources :collections, only: %i[new create edit update] do
    resources :works, shallow: true, only: %i[new create show edit update] do
      resource :review, only: :create
    end
  end

  # @note Only admins should be able to access the Sidekiq web UI.  But this is accomplished by Puppet
  # configuration restricting access using a shib workgroup, so the request doesn't reach the app if the user
  # isn't authorized (because ApplicationController#current_user doesn't get called until after this runs).
  mount Sidekiq::Web => '/queues'
end
