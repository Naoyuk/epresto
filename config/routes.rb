# frozen_string_literal: true

Rails.application.routes.draw do
  get 'pages/home'
  devise_for :users
  root 'pages#home'
end
