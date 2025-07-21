Rails.application.routes.draw do
  namespace :admin do
    # Root route for admin (goes to Admin::AdminController#dashboard)
    root to: "admin#dashboard"
    
    # Main admin controller routes (Admin::AdminController)
    get 'dashboard', to: 'admin#dashboard'
    get 'posts', to: 'admin#posts'          # Overview of posts
    get 'comments', to: 'admin#comments'    # Overview of comments
    
    # Users management (Admin::UsersController)
    resources :users, param: :username do
      member do
        patch :toggle_admin  # PATCH request to toggle admin status
      end
    end
    # Reports managmetn
    resources :reports, only: [:index, :show, :update]
    # Posts management (Admin::PostsController) 
    resources :posts, only: [:index, :show, :edit, :update, :destroy]
    
    # Comments management 
    resources :comments, only: [:index, :show, :destroy]
  end
  resources :posts do
    resources :comments, only: [:create, :destroy]
    member do
      post :toggle_like
    end
  end
  get "pages/home"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "/dashboard", to: "users#index"
  # users profile
  # Replace your current profile routes with:
  get "/profile(/:username)", to: "users#profile", as: :profile
  get "/users/:username", to: "users#show", as: :user_profile
  get "/suggested_followers", to: "users#all_users"
  # Follow/unfollow routes
  post "/users/:username/follow", to: "users#follow", as: :user_follows
  delete "/users/:username/unfollow", to: "users#unfollow", as: :user_unfollows
  # Messages routes
  resources :messages, only: [:index] do
    member do
      patch :mark_as_read
    end
  end
  resources :reports, only: [:create]
  # Conversations with specific users
  get 'messages/:username', to: 'messages#show', as: 'conversation'
  post 'messages/:username', to: 'messages#create'
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "users#index"
end
