Rails.application.routes.draw do

  use_doorkeeper do
    controllers tokens: 'tokens'
  end

  constraints subdomain: 'api' do
    get 'ping', to: 'ping#index'

    get 'users/me', to: 'users#me'
    post 'users/me', to: 'users#update'
    resources :users, only: [:create, :show]
    
    resources :addresses, only: [:index]

    resources :visits, only: [:create]

    resources :rankings, only: [:index]
  end

end
