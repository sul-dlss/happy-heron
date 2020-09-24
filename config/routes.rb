# typed: strict
# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'welcome#show'
  resource 'welcome', only: 'show'

  resources :works, only: [:new, :create, :show]
end
