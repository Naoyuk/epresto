# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  get '/users', to: 'users#index'
  get '/profile', to: 'users#show'
  get 'pages/home'

  resources :items do
    collection do
      post :import
    end
  end

  resources :orders do
    collection do
      post :import
      post :acknowledge
    end
  end

  resources :shiptos

  root 'pages#home'
end
