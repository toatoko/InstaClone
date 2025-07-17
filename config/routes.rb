Rails.application.routes.draw do
  resources :posts
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
