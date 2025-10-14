Rails.application.routes.draw do
  # Mqtt routes
  get '/mqtt_messages', to: 'mqtt_messages#index'
  get 'mqtt_messages/show'
  # Home routes
  root "home#index"
  get '/contact', to: 'home#contact'
  get '/document', to: 'home#document'
  get '/architect', to: 'document#architect'
end
