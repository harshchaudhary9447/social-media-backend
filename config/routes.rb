Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  # Other routes...

  resources :posts, only: [ :index, :create, :show, :update, :destroy ] do
    resources :comments, only: [ :index, :create, :destroy ]
  end


  # Rails.application.routes.draw do
  #   devise_for :users
  #   resources :posts, only: [:index, :create, :show, :update, :destroy] do
  #     resources :comments, only: [:index, :create, :destroy]
  #   end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
