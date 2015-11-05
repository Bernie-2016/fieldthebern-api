Rails.application.routes.draw do

  use_doorkeeper do
    controllers tokens: 'tokens'
  end

  constraints subdomain: 'api' do
    get 'ping', to: 'ping#index'
    get 'compatibility', to: 'compatibility#show'

    get 'users/me', to: 'users#me'
    post 'users/me', to: 'users#update'

    resources :users, only: [:create, :show]

    resources :addresses, only: [:index]

    resources :visits, only: [:create]

    resources :rankings, only: [:index]

    resources :devices, only: [:create]
  end
end
