Rails.application.routes.draw do
  # Public report creation
  resources :reports, only: [ :create ]

  # Admin routes
  namespace :admin do
    # Root dashboard
    root to: "admin#dashboard"
    get "dashboard", to: "admin#dashboard"
    get "posts",     to: "admin#posts"
    get "comments",  to: "admin#comments"

    # Admin::UsersController
    resources :users, param: :username do
      member do
        patch :toggle_admin
        patch :resolve_all_reports, to: "reports#resolve_all"
      end
      resources :reports, only: [ :index ], controller: "reports"
    end

    # Admin::ReportsController
    resources :reports, only: [ :index, :show ] do
      member do
        patch :resolve
        patch :dismiss
      end
    end

    # Admin::PostsController
    resources :posts, only: [ :index, :show, :edit, :update, :destroy ] do
      member do
        patch :resolve_all_reports, to: "reports#resolve_all"
      end
      resources :reports, only: [ :index ], controller: "reports"
    end

    # Admin::CommentsController
    resources :comments, only: [ :index, :show, :destroy ] do
      member do
        patch :resolve_all_reports, to: "reports#resolve_all"
      end
      resources :reports, only: [ :index ], controller: "reports"
    end
  end

  # Posts & Comments
  resources :posts do
    resources :comments, only: [ :create, :destroy ]
    member do
      post :toggle_like
    end
  end

  # Users and Profiles
  devise_for :users
  get "/dashboard", to: "users#index"
  get "/profile(/:username)", to: "users#profile", as: :profile
  get "/users/:username",     to: "users#show", as: :user_profile
  get "/suggested_followers", to: "users#all_users"
  post "/users/:username/follow",   to: "users#follow",   as: :user_follows
  delete "/users/:username/unfollow", to: "users#unfollow", as: :user_unfollows

  # Messaging
  resources :messages, only: [ :index ] do
    member do
      patch :mark_as_read
    end
  end
  get "messages/:username", to: "messages#show", as: "conversation"
  post "messages/:username", to: "messages#create"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "users#index"
end
