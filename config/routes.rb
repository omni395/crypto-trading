Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  get "up" => "rails/health#show", as: :rails_health_check

  root to: "main#index"
  resources :main, only: [:index] do
    collection do
      post :refresh_cryptocurrencies
    end
  end
end
