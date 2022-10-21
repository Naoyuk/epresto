# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  get '/users', to: 'users#index'
  get '/profile', to: 'users#show'
  get 'pages/home'

  resources :items

  root 'pages#home'
end
