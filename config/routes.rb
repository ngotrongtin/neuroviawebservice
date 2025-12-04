Rails.application.routes.draw do

  # === Public routes (home page, contact, etc.) ===
  root "home#index"
  get '/contact', to: 'home#contact'
  get '/document', to: 'home#document'
  get '/architect', to: 'document#architect'

  # === Authentication
  devise_for :users, controllers: {
    sessions: 'auth/sessions',
    registrations: 'auth/registrations',
    passwords: 'auth/passwords'
  }
  namespace :auth do
    get '/oauth2callback', to: 'oauth#callback'
  end
  # === Admin namespace ===
  namespace :admin do
    root "dashboard#index"

    resources :users, only: [:index, :update, :destroy]
    namespace :iot do
      resources :mqtt_monitor, only: [:index, :show]
      resources :media_monitor, only: [:index]
      #resources :devices
    end

    # namespace :statistics do
    #   get 'usage', to: 'usage#index'
    #   get 'revenue', to: 'revenue#index'
    # end
  end
  
  # API for mobile clients (JWT)
  namespace :api do
    namespace :v1 do
      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'
      post 'refresh', to: 'tokens#create'
      get 'profile', to: 'profiles#show'
    end
  end
end
