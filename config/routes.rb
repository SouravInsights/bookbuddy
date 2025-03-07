Rails.application.routes.draw do
  # Delete or comment out all those individual GET routes and replace with these:
  
  # Set the root path
  root "bookmarks#index"
  
  # Users and sessions routes
  get "signup", to: "users#new"
  post "signup", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  
  # RESTful resources
  resources :bookmarks
  resources :tags, only: [:index, :show]
  
  # Keep the health check
  get "up" => "rails/health#show", as: :rails_health_check
end