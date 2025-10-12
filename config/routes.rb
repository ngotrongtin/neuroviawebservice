Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
  get '/contact', to: 'home#contact'
  get '/document', to: 'home#document'
  get '/architect', to: 'document#architect'
end
