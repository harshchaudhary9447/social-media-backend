Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  resources :posts, only: [ :index, :create, :show, :update, :destroy ] do
    resources :comments, only: [ :index, :create, :destroy ]
  end

  # Admin routes - Correcting the namespace
  # i am adding this patch url patch 'admin/users/:id/toggle_activation', to: 'admin/users#toggle_activation'
  # which is converted into differnt format like below.
  namespace :admin do
    resources :users, only: [ :index, :create ] do
      member do
        patch :toggle_activation
      end
    end
  end


  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
