Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  # Normal user routes
  resources :posts, only: [ :index, :create, :show, :update, :destroy ] do
    resources :comments, only: [ :index, :create, :destroy ]
  end

  # Admin routes
  namespace :admin do
    resources :users, only: [ :index, :create ] do
      member do
        patch :toggle_activation
      end
    end

    # Admin can delete any post or comment
    resources :posts, only: [ :create, :update, :destroy ]
    resources :comments, only: [ :create, :update, :destroy ]
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
