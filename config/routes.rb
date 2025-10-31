Rails.application.routes.draw do

  # === Public routes (home page, contact, etc.) ===
  root "home#index"
  get '/contact', to: 'home#contact'
  get '/document', to: 'home#document'
  get '/architect', to: 'document#architect'

  # === Authentication
  devise_for :users, controllers: {
    sessions: 'auth/sessions',
    registrations: 'auth/registrations'
  }

  # === Admin namespace ===
  namespace :admin do
    root "dashboard#index"

    resources :users
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
end
