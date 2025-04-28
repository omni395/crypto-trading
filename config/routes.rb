Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  # Add custom sign out route
  devise_scope :user do  
    get '/users/sign_out' => 'devise/sessions#destroy'     
  end

  root to: "main#index"
  resources :main, only: [:index] do
    collection do
      post :refresh_cryptocurrencies
    end
  end

  # API
  namespace :api do
    resources :instruments, only: [:index] do
      collection do
        get :favorites
      end
    end
    resources :dictionaries, only: [:index]
    resources :dynamics, only: [:index] do
      # collection do
      #   post :refresh
      # end
    end
    resources :favorites, only: [:index, :create, :destroy]
    get 'exchange', to: 'exchange#index'
    resource :user_settings, only: [:show, :update], controller: 'user_settings'
  end

  namespace :admin do
    resources :roles
    resources :user_roles, only: [:index, :new, :create, :destroy]
    resources :exchanges
  end
  
  # Add health check route
  get "up" => "rails/health#show", as: :rails_health_check
end