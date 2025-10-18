Rails.application.routes.draw do
  # Home routes
  root "home#index"
  get '/contact', to: 'home#contact'
  get '/document', to: 'home#document'
  get '/architect', to: 'document#architect'
  # service routes
  get '/services', to: 'services#index'
  get '/dashboard/monitoring', to: 'mqtt_messages#index'
end
