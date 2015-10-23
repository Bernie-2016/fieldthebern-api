source 'https://rubygems.org'

gem 'rails', '4.2.4'

gem 'rails-api'

gem 'active_model_serializers', github: 'rails-api/active_model_serializers'

gem 'rack-cors', :require => 'rack/cors'

gem 'doorkeeper'
gem 'clearance'

gem 'spring', :group => :development

gem 'hashie'

gem 'pg'

gem 'koala'

gem 'sidekiq'

gem 'geokit-rails'

gem 'easypost'

# paperclip master currently doesn't work with new version of AWS SDK
gem 'paperclip', :git=> 'https://github.com/thoughtbot/paperclip', :ref => '523bd46c768226893f23889079a7aa9c73b57d68'

gem 'aws-sdk'

gem 'unicorn'

group :development, :production do
  gem 'rails_12factor'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails'

  gem 'pry-rails'
  gem 'pry'
  gem 'pry-nav'
end

group :development do
  gem 'faker'
end

group :test do
  gem 'factory_girl_rails'
  gem 'oauth2'
  gem 'vcr'
  gem 'webmock'
end
