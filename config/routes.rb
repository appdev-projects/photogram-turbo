Rails.application.routes.draw do
  root "users#feed"

  devise_for :users

  resources :comments, except: [ :index, :show ]
  resources :follow_requests, only: [ :create, :update, :destroy ]
  resources :likes, only: [ :create, :destroy ]
  resources :photos, except: [ :index ]
  resources :users, only: [ :index ]

  get ":username" => "users#show", as: :user
  get ":username/liked" => "users#liked", as: :liked
  get ":username/feed" => "users#feed", as: :feed
  get ":username/discover" => "users#discover", as: :discover
end
