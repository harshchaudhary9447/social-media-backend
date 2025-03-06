Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  # Normal user routes
  resources :posts, only: [ :index, :create, :show, :update, :destroy ] do
    resources :likes, only: [ :create ] # Keep create as it is
    delete "likes", to: "likes#destroy" # Allow deleting like without needing like ID

    resources :comments, only: [ :index, :create, :destroy ] do
      resources :likes, only: [ :create ] # Keep create as it is
      delete "likes", to: "likes#destroy" # Allow deleting comment like without needing like ID
    end
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

    # Reports Routes (Users, Active Users, Posts)
    resources :reports, only: [] do
      collection do
        get :users_report
        get :active_users_report
        get :posts_report
      end
    end
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
