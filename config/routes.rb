# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  get '/users', to: 'users#index'
  get '/profile', to: 'users#show'
  get '/edit_user', to: 'users#edit'
  get 'pages/home'
  resources :users

  resources :items do
    collection do
      post :import
    end
  end

  resources :orders do
    collection do
      post :import
      post :acknowledge
      post :convert_to_bulk
      post :convert_to_regular
    end
  end

  resources :shiptos

  root 'orders#index'
end
