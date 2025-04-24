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

  # Add health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # API: settings
  namespace :api do
    resource :settings, only: [:show, :update], controller: 'api/settings'
  end
end
