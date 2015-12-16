Rails.application.routes.draw do

  use_doorkeeper do
    controllers tokens: 'tokens'
    skip_controllers :applications, :authorized_applications
  end

  constraints subdomain: 'api' do
    get 'ping', to: 'ping#index'
    get 'compatibility', to: 'compatibility#show'

    get 'users/me', to: 'users#me'
    patch 'users/me', to: 'users#update'

    get 'users/lookup', to: 'users#lookup'

    resources :users, only: [:create, :show]

    resources :addresses, only: [:index]

    resources :visits, only: [:create]

    resources :rankings, only: [:index]

    resources :devices, only: [:create]
  end

  get '/(*path)' => "ember_index#index", as: :root, format: :html
end
