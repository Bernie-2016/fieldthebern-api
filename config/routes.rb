Rails.application.routes.draw do

  constraints subdomain: 'api' do
    get 'ping', to: 'ping#index'
  end
  
end
