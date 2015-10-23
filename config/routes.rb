Rails.application.routes.draw do

  use_doorkeeper do
    controllers tokens: 'tokens'
  end

  constraints subdomain: 'api' do
    get 'ping', to: 'ping#index'

    resources :users, only: [:create]
    resources :addresses, only: [:index]

    resources :visits, only: [:create]

    resources :rankings, only: [:index]
  end

end
