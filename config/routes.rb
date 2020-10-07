# typed: strict
# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'welcome#show'
  resource 'welcome', only: 'show'

  resources :works, only: %i[new create show]

  mount Sidekiq::Web => '/queues'
end
