Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'devise/sessions',
    confirmations: 'devise/confirmations',
    registrations: 'devise/registrations',
    unlocks: 'devise/unlocks',
    passwords: 'devise/passwords',
    omniauth_callbacks: 'devise/omniauth_callbacks'
  }

  resources :matches do
    collection do 
      get 'popular' #, :controller => :matches, :action => 'popular'
      get 'feed'
    end
    member do
      post 'matchthat'
      get 'user_tally'
    end
  end
  get '/search/show/:search_params/:page', :controller => :search, :action => 'show'
  post '/search/:search_params/:page', :controller => :search, :action => 'create'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "matches#index"
end
